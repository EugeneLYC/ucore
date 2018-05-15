
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 50 12 00       	mov    $0x125000,%eax
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
c0100020:	a3 00 50 12 c0       	mov    %eax,0xc0125000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 40 12 c0       	mov    $0xc0124000,%esp
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
c010003c:	ba 64 a1 12 c0       	mov    $0xc012a164,%edx
c0100041:	b8 00 70 12 c0       	mov    $0xc0127000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	83 ec 04             	sub    $0x4,%esp
c010004d:	50                   	push   %eax
c010004e:	6a 00                	push   $0x0
c0100050:	68 00 70 12 c0       	push   $0xc0127000
c0100055:	e8 ac 8b 00 00       	call   c0108c06 <memset>
c010005a:	83 c4 10             	add    $0x10,%esp

    cons_init();                // init the console
c010005d:	e8 fa 1c 00 00       	call   c0101d5c <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100062:	c7 45 f4 a0 94 10 c0 	movl   $0xc01094a0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c0100069:	83 ec 08             	sub    $0x8,%esp
c010006c:	ff 75 f4             	pushl  -0xc(%ebp)
c010006f:	68 bc 94 10 c0       	push   $0xc01094bc
c0100074:	e8 11 02 00 00       	call   c010028a <cprintf>
c0100079:	83 c4 10             	add    $0x10,%esp

    print_kerninfo();
c010007c:	e8 a8 08 00 00       	call   c0100929 <print_kerninfo>

    grade_backtrace();
c0100081:	e8 8b 00 00 00       	call   c0100111 <grade_backtrace>

    pmm_init();                 // init physical memory management
c0100086:	e8 0a 6c 00 00       	call   c0106c95 <pmm_init>

    pic_init();                 // init interrupt controller
c010008b:	e8 3e 1e 00 00       	call   c0101ece <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100090:	e8 9f 1f 00 00       	call   c0102034 <idt_init>

    vmm_init();                 // init virtual memory management
c0100095:	e8 3f 34 00 00       	call   c01034d9 <vmm_init>
    proc_init();                // init process table
c010009a:	e8 35 85 00 00       	call   c01085d4 <proc_init>
    
    ide_init();                 // init ide devices
c010009f:	e8 87 0c 00 00       	call   c0100d2b <ide_init>
    swap_init();                // init swap
c01000a4:	e8 e6 48 00 00       	call   c010498f <swap_init>

    clock_init();               // init clock interrupt
c01000a9:	e8 55 14 00 00       	call   c0101503 <clock_init>
    intr_enable();              // enable irq interrupt
c01000ae:	e8 58 1f 00 00       	call   c010200b <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000b3:	e8 bc 86 00 00       	call   c0108774 <cpu_idle>

c01000b8 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000b8:	55                   	push   %ebp
c01000b9:	89 e5                	mov    %esp,%ebp
c01000bb:	83 ec 08             	sub    $0x8,%esp
    mon_backtrace(0, NULL, NULL);
c01000be:	83 ec 04             	sub    $0x4,%esp
c01000c1:	6a 00                	push   $0x0
c01000c3:	6a 00                	push   $0x0
c01000c5:	6a 00                	push   $0x0
c01000c7:	e8 f3 0b 00 00       	call   c0100cbf <mon_backtrace>
c01000cc:	83 c4 10             	add    $0x10,%esp
}
c01000cf:	90                   	nop
c01000d0:	c9                   	leave  
c01000d1:	c3                   	ret    

c01000d2 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000d2:	55                   	push   %ebp
c01000d3:	89 e5                	mov    %esp,%ebp
c01000d5:	53                   	push   %ebx
c01000d6:	83 ec 04             	sub    $0x4,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d9:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000dc:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000df:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01000e5:	51                   	push   %ecx
c01000e6:	52                   	push   %edx
c01000e7:	53                   	push   %ebx
c01000e8:	50                   	push   %eax
c01000e9:	e8 ca ff ff ff       	call   c01000b8 <grade_backtrace2>
c01000ee:	83 c4 10             	add    $0x10,%esp
}
c01000f1:	90                   	nop
c01000f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01000f5:	c9                   	leave  
c01000f6:	c3                   	ret    

c01000f7 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000f7:	55                   	push   %ebp
c01000f8:	89 e5                	mov    %esp,%ebp
c01000fa:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace1(arg0, arg2);
c01000fd:	83 ec 08             	sub    $0x8,%esp
c0100100:	ff 75 10             	pushl  0x10(%ebp)
c0100103:	ff 75 08             	pushl  0x8(%ebp)
c0100106:	e8 c7 ff ff ff       	call   c01000d2 <grade_backtrace1>
c010010b:	83 c4 10             	add    $0x10,%esp
}
c010010e:	90                   	nop
c010010f:	c9                   	leave  
c0100110:	c3                   	ret    

c0100111 <grade_backtrace>:

void
grade_backtrace(void) {
c0100111:	55                   	push   %ebp
c0100112:	89 e5                	mov    %esp,%ebp
c0100114:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100117:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010011c:	83 ec 04             	sub    $0x4,%esp
c010011f:	68 00 00 ff ff       	push   $0xffff0000
c0100124:	50                   	push   %eax
c0100125:	6a 00                	push   $0x0
c0100127:	e8 cb ff ff ff       	call   c01000f7 <grade_backtrace0>
c010012c:	83 c4 10             	add    $0x10,%esp
}
c010012f:	90                   	nop
c0100130:	c9                   	leave  
c0100131:	c3                   	ret    

c0100132 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100132:	55                   	push   %ebp
c0100133:	89 e5                	mov    %esp,%ebp
c0100135:	83 ec 18             	sub    $0x18,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100138:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010013b:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010013e:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100141:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100144:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100148:	0f b7 c0             	movzwl %ax,%eax
c010014b:	83 e0 03             	and    $0x3,%eax
c010014e:	89 c2                	mov    %eax,%edx
c0100150:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c0100155:	83 ec 04             	sub    $0x4,%esp
c0100158:	52                   	push   %edx
c0100159:	50                   	push   %eax
c010015a:	68 c1 94 10 c0       	push   $0xc01094c1
c010015f:	e8 26 01 00 00       	call   c010028a <cprintf>
c0100164:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  cs = %x\n", round, reg1);
c0100167:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010016b:	0f b7 d0             	movzwl %ax,%edx
c010016e:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c0100173:	83 ec 04             	sub    $0x4,%esp
c0100176:	52                   	push   %edx
c0100177:	50                   	push   %eax
c0100178:	68 cf 94 10 c0       	push   $0xc01094cf
c010017d:	e8 08 01 00 00       	call   c010028a <cprintf>
c0100182:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ds = %x\n", round, reg2);
c0100185:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100189:	0f b7 d0             	movzwl %ax,%edx
c010018c:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c0100191:	83 ec 04             	sub    $0x4,%esp
c0100194:	52                   	push   %edx
c0100195:	50                   	push   %eax
c0100196:	68 dd 94 10 c0       	push   $0xc01094dd
c010019b:	e8 ea 00 00 00       	call   c010028a <cprintf>
c01001a0:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  es = %x\n", round, reg3);
c01001a3:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001a7:	0f b7 d0             	movzwl %ax,%edx
c01001aa:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c01001af:	83 ec 04             	sub    $0x4,%esp
c01001b2:	52                   	push   %edx
c01001b3:	50                   	push   %eax
c01001b4:	68 eb 94 10 c0       	push   $0xc01094eb
c01001b9:	e8 cc 00 00 00       	call   c010028a <cprintf>
c01001be:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ss = %x\n", round, reg4);
c01001c1:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001c5:	0f b7 d0             	movzwl %ax,%edx
c01001c8:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c01001cd:	83 ec 04             	sub    $0x4,%esp
c01001d0:	52                   	push   %edx
c01001d1:	50                   	push   %eax
c01001d2:	68 f9 94 10 c0       	push   $0xc01094f9
c01001d7:	e8 ae 00 00 00       	call   c010028a <cprintf>
c01001dc:	83 c4 10             	add    $0x10,%esp
    round ++;
c01001df:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c01001e4:	83 c0 01             	add    $0x1,%eax
c01001e7:	a3 00 70 12 c0       	mov    %eax,0xc0127000
}
c01001ec:	90                   	nop
c01001ed:	c9                   	leave  
c01001ee:	c3                   	ret    

c01001ef <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001ef:	55                   	push   %ebp
c01001f0:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c01001f2:	90                   	nop
c01001f3:	5d                   	pop    %ebp
c01001f4:	c3                   	ret    

c01001f5 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c01001f5:	55                   	push   %ebp
c01001f6:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c01001f8:	90                   	nop
c01001f9:	5d                   	pop    %ebp
c01001fa:	c3                   	ret    

c01001fb <lab1_switch_test>:

static void
lab1_switch_test(void) {
c01001fb:	55                   	push   %ebp
c01001fc:	89 e5                	mov    %esp,%ebp
c01001fe:	83 ec 08             	sub    $0x8,%esp
    lab1_print_cur_status();
c0100201:	e8 2c ff ff ff       	call   c0100132 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100206:	83 ec 0c             	sub    $0xc,%esp
c0100209:	68 08 95 10 c0       	push   $0xc0109508
c010020e:	e8 77 00 00 00       	call   c010028a <cprintf>
c0100213:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_user();
c0100216:	e8 d4 ff ff ff       	call   c01001ef <lab1_switch_to_user>
    lab1_print_cur_status();
c010021b:	e8 12 ff ff ff       	call   c0100132 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100220:	83 ec 0c             	sub    $0xc,%esp
c0100223:	68 28 95 10 c0       	push   $0xc0109528
c0100228:	e8 5d 00 00 00       	call   c010028a <cprintf>
c010022d:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_kernel();
c0100230:	e8 c0 ff ff ff       	call   c01001f5 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100235:	e8 f8 fe ff ff       	call   c0100132 <lab1_print_cur_status>
}
c010023a:	90                   	nop
c010023b:	c9                   	leave  
c010023c:	c3                   	ret    

c010023d <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010023d:	55                   	push   %ebp
c010023e:	89 e5                	mov    %esp,%ebp
c0100240:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
c0100243:	83 ec 0c             	sub    $0xc,%esp
c0100246:	ff 75 08             	pushl  0x8(%ebp)
c0100249:	e8 3f 1b 00 00       	call   c0101d8d <cons_putc>
c010024e:	83 c4 10             	add    $0x10,%esp
    (*cnt) ++;
c0100251:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100254:	8b 00                	mov    (%eax),%eax
c0100256:	8d 50 01             	lea    0x1(%eax),%edx
c0100259:	8b 45 0c             	mov    0xc(%ebp),%eax
c010025c:	89 10                	mov    %edx,(%eax)
}
c010025e:	90                   	nop
c010025f:	c9                   	leave  
c0100260:	c3                   	ret    

c0100261 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100261:	55                   	push   %ebp
c0100262:	89 e5                	mov    %esp,%ebp
c0100264:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
c0100267:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010026e:	ff 75 0c             	pushl  0xc(%ebp)
c0100271:	ff 75 08             	pushl  0x8(%ebp)
c0100274:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100277:	50                   	push   %eax
c0100278:	68 3d 02 10 c0       	push   $0xc010023d
c010027d:	e8 ba 8c 00 00       	call   c0108f3c <vprintfmt>
c0100282:	83 c4 10             	add    $0x10,%esp
    return cnt;
c0100285:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100288:	c9                   	leave  
c0100289:	c3                   	ret    

c010028a <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c010028a:	55                   	push   %ebp
c010028b:	89 e5                	mov    %esp,%ebp
c010028d:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0100290:	8d 45 0c             	lea    0xc(%ebp),%eax
c0100293:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100296:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100299:	83 ec 08             	sub    $0x8,%esp
c010029c:	50                   	push   %eax
c010029d:	ff 75 08             	pushl  0x8(%ebp)
c01002a0:	e8 bc ff ff ff       	call   c0100261 <vcprintf>
c01002a5:	83 c4 10             	add    $0x10,%esp
c01002a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002ae:	c9                   	leave  
c01002af:	c3                   	ret    

c01002b0 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002b0:	55                   	push   %ebp
c01002b1:	89 e5                	mov    %esp,%ebp
c01002b3:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
c01002b6:	83 ec 0c             	sub    $0xc,%esp
c01002b9:	ff 75 08             	pushl  0x8(%ebp)
c01002bc:	e8 cc 1a 00 00       	call   c0101d8d <cons_putc>
c01002c1:	83 c4 10             	add    $0x10,%esp
}
c01002c4:	90                   	nop
c01002c5:	c9                   	leave  
c01002c6:	c3                   	ret    

c01002c7 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002c7:	55                   	push   %ebp
c01002c8:	89 e5                	mov    %esp,%ebp
c01002ca:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
c01002cd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002d4:	eb 14                	jmp    c01002ea <cputs+0x23>
        cputch(c, &cnt);
c01002d6:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002da:	83 ec 08             	sub    $0x8,%esp
c01002dd:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002e0:	52                   	push   %edx
c01002e1:	50                   	push   %eax
c01002e2:	e8 56 ff ff ff       	call   c010023d <cputch>
c01002e7:	83 c4 10             	add    $0x10,%esp
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01002ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01002ed:	8d 50 01             	lea    0x1(%eax),%edx
c01002f0:	89 55 08             	mov    %edx,0x8(%ebp)
c01002f3:	0f b6 00             	movzbl (%eax),%eax
c01002f6:	88 45 f7             	mov    %al,-0x9(%ebp)
c01002f9:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01002fd:	75 d7                	jne    c01002d6 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01002ff:	83 ec 08             	sub    $0x8,%esp
c0100302:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0100305:	50                   	push   %eax
c0100306:	6a 0a                	push   $0xa
c0100308:	e8 30 ff ff ff       	call   c010023d <cputch>
c010030d:	83 c4 10             	add    $0x10,%esp
    return cnt;
c0100310:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100313:	c9                   	leave  
c0100314:	c3                   	ret    

c0100315 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c0100315:	55                   	push   %ebp
c0100316:	89 e5                	mov    %esp,%ebp
c0100318:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c010031b:	e8 b6 1a 00 00       	call   c0101dd6 <cons_getc>
c0100320:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100323:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100327:	74 f2                	je     c010031b <getchar+0x6>
        /* do nothing */;
    return c;
c0100329:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010032c:	c9                   	leave  
c010032d:	c3                   	ret    

c010032e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010032e:	55                   	push   %ebp
c010032f:	89 e5                	mov    %esp,%ebp
c0100331:	83 ec 18             	sub    $0x18,%esp
    if (prompt != NULL) {
c0100334:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100338:	74 13                	je     c010034d <readline+0x1f>
        cprintf("%s", prompt);
c010033a:	83 ec 08             	sub    $0x8,%esp
c010033d:	ff 75 08             	pushl  0x8(%ebp)
c0100340:	68 47 95 10 c0       	push   $0xc0109547
c0100345:	e8 40 ff ff ff       	call   c010028a <cprintf>
c010034a:	83 c4 10             	add    $0x10,%esp
    }
    int i = 0, c;
c010034d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100354:	e8 bc ff ff ff       	call   c0100315 <getchar>
c0100359:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c010035c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100360:	79 0a                	jns    c010036c <readline+0x3e>
            return NULL;
c0100362:	b8 00 00 00 00       	mov    $0x0,%eax
c0100367:	e9 82 00 00 00       	jmp    c01003ee <readline+0xc0>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010036c:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100370:	7e 2b                	jle    c010039d <readline+0x6f>
c0100372:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100379:	7f 22                	jg     c010039d <readline+0x6f>
            cputchar(c);
c010037b:	83 ec 0c             	sub    $0xc,%esp
c010037e:	ff 75 f0             	pushl  -0x10(%ebp)
c0100381:	e8 2a ff ff ff       	call   c01002b0 <cputchar>
c0100386:	83 c4 10             	add    $0x10,%esp
            buf[i ++] = c;
c0100389:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010038c:	8d 50 01             	lea    0x1(%eax),%edx
c010038f:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100392:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100395:	88 90 20 70 12 c0    	mov    %dl,-0x3fed8fe0(%eax)
c010039b:	eb 4c                	jmp    c01003e9 <readline+0xbb>
        }
        else if (c == '\b' && i > 0) {
c010039d:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003a1:	75 1a                	jne    c01003bd <readline+0x8f>
c01003a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003a7:	7e 14                	jle    c01003bd <readline+0x8f>
            cputchar(c);
c01003a9:	83 ec 0c             	sub    $0xc,%esp
c01003ac:	ff 75 f0             	pushl  -0x10(%ebp)
c01003af:	e8 fc fe ff ff       	call   c01002b0 <cputchar>
c01003b4:	83 c4 10             	add    $0x10,%esp
            i --;
c01003b7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01003bb:	eb 2c                	jmp    c01003e9 <readline+0xbb>
        }
        else if (c == '\n' || c == '\r') {
c01003bd:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003c1:	74 06                	je     c01003c9 <readline+0x9b>
c01003c3:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003c7:	75 8b                	jne    c0100354 <readline+0x26>
            cputchar(c);
c01003c9:	83 ec 0c             	sub    $0xc,%esp
c01003cc:	ff 75 f0             	pushl  -0x10(%ebp)
c01003cf:	e8 dc fe ff ff       	call   c01002b0 <cputchar>
c01003d4:	83 c4 10             	add    $0x10,%esp
            buf[i] = '\0';
c01003d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003da:	05 20 70 12 c0       	add    $0xc0127020,%eax
c01003df:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003e2:	b8 20 70 12 c0       	mov    $0xc0127020,%eax
c01003e7:	eb 05                	jmp    c01003ee <readline+0xc0>
        }
    }
c01003e9:	e9 66 ff ff ff       	jmp    c0100354 <readline+0x26>
}
c01003ee:	c9                   	leave  
c01003ef:	c3                   	ret    

c01003f0 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c01003f0:	55                   	push   %ebp
c01003f1:	89 e5                	mov    %esp,%ebp
c01003f3:	83 ec 18             	sub    $0x18,%esp
    if (is_panic) {
c01003f6:	a1 20 74 12 c0       	mov    0xc0127420,%eax
c01003fb:	85 c0                	test   %eax,%eax
c01003fd:	75 5f                	jne    c010045e <__panic+0x6e>
        goto panic_dead;
    }
    is_panic = 1;
c01003ff:	c7 05 20 74 12 c0 01 	movl   $0x1,0xc0127420
c0100406:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100409:	8d 45 14             	lea    0x14(%ebp),%eax
c010040c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c010040f:	83 ec 04             	sub    $0x4,%esp
c0100412:	ff 75 0c             	pushl  0xc(%ebp)
c0100415:	ff 75 08             	pushl  0x8(%ebp)
c0100418:	68 4a 95 10 c0       	push   $0xc010954a
c010041d:	e8 68 fe ff ff       	call   c010028a <cprintf>
c0100422:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
c0100425:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100428:	83 ec 08             	sub    $0x8,%esp
c010042b:	50                   	push   %eax
c010042c:	ff 75 10             	pushl  0x10(%ebp)
c010042f:	e8 2d fe ff ff       	call   c0100261 <vcprintf>
c0100434:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
c0100437:	83 ec 0c             	sub    $0xc,%esp
c010043a:	68 66 95 10 c0       	push   $0xc0109566
c010043f:	e8 46 fe ff ff       	call   c010028a <cprintf>
c0100444:	83 c4 10             	add    $0x10,%esp
    
    cprintf("stack trackback:\n");
c0100447:	83 ec 0c             	sub    $0xc,%esp
c010044a:	68 68 95 10 c0       	push   $0xc0109568
c010044f:	e8 36 fe ff ff       	call   c010028a <cprintf>
c0100454:	83 c4 10             	add    $0x10,%esp
    print_stackframe();
c0100457:	e8 17 06 00 00       	call   c0100a73 <print_stackframe>
c010045c:	eb 01                	jmp    c010045f <__panic+0x6f>
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
        goto panic_dead;
c010045e:	90                   	nop
    print_stackframe();
    
    va_end(ap);

panic_dead:
    intr_disable();
c010045f:	e8 ae 1b 00 00       	call   c0102012 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100464:	83 ec 0c             	sub    $0xc,%esp
c0100467:	6a 00                	push   $0x0
c0100469:	e8 77 07 00 00       	call   c0100be5 <kmonitor>
c010046e:	83 c4 10             	add    $0x10,%esp
    }
c0100471:	eb f1                	jmp    c0100464 <__panic+0x74>

c0100473 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100473:	55                   	push   %ebp
c0100474:	89 e5                	mov    %esp,%ebp
c0100476:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    va_start(ap, fmt);
c0100479:	8d 45 14             	lea    0x14(%ebp),%eax
c010047c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c010047f:	83 ec 04             	sub    $0x4,%esp
c0100482:	ff 75 0c             	pushl  0xc(%ebp)
c0100485:	ff 75 08             	pushl  0x8(%ebp)
c0100488:	68 7a 95 10 c0       	push   $0xc010957a
c010048d:	e8 f8 fd ff ff       	call   c010028a <cprintf>
c0100492:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
c0100495:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100498:	83 ec 08             	sub    $0x8,%esp
c010049b:	50                   	push   %eax
c010049c:	ff 75 10             	pushl  0x10(%ebp)
c010049f:	e8 bd fd ff ff       	call   c0100261 <vcprintf>
c01004a4:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
c01004a7:	83 ec 0c             	sub    $0xc,%esp
c01004aa:	68 66 95 10 c0       	push   $0xc0109566
c01004af:	e8 d6 fd ff ff       	call   c010028a <cprintf>
c01004b4:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
c01004b7:	90                   	nop
c01004b8:	c9                   	leave  
c01004b9:	c3                   	ret    

c01004ba <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004ba:	55                   	push   %ebp
c01004bb:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01004bd:	a1 20 74 12 c0       	mov    0xc0127420,%eax
}
c01004c2:	5d                   	pop    %ebp
c01004c3:	c3                   	ret    

c01004c4 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01004c4:	55                   	push   %ebp
c01004c5:	89 e5                	mov    %esp,%ebp
c01004c7:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01004ca:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004cd:	8b 00                	mov    (%eax),%eax
c01004cf:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004d2:	8b 45 10             	mov    0x10(%ebp),%eax
c01004d5:	8b 00                	mov    (%eax),%eax
c01004d7:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004e1:	e9 d2 00 00 00       	jmp    c01005b8 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c01004e6:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004ec:	01 d0                	add    %edx,%eax
c01004ee:	89 c2                	mov    %eax,%edx
c01004f0:	c1 ea 1f             	shr    $0x1f,%edx
c01004f3:	01 d0                	add    %edx,%eax
c01004f5:	d1 f8                	sar    %eax
c01004f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01004fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004fd:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100500:	eb 04                	jmp    c0100506 <stab_binsearch+0x42>
            m --;
c0100502:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100506:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100509:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010050c:	7c 1f                	jl     c010052d <stab_binsearch+0x69>
c010050e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100511:	89 d0                	mov    %edx,%eax
c0100513:	01 c0                	add    %eax,%eax
c0100515:	01 d0                	add    %edx,%eax
c0100517:	c1 e0 02             	shl    $0x2,%eax
c010051a:	89 c2                	mov    %eax,%edx
c010051c:	8b 45 08             	mov    0x8(%ebp),%eax
c010051f:	01 d0                	add    %edx,%eax
c0100521:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100525:	0f b6 c0             	movzbl %al,%eax
c0100528:	3b 45 14             	cmp    0x14(%ebp),%eax
c010052b:	75 d5                	jne    c0100502 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c010052d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100530:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100533:	7d 0b                	jge    c0100540 <stab_binsearch+0x7c>
            l = true_m + 1;
c0100535:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100538:	83 c0 01             	add    $0x1,%eax
c010053b:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010053e:	eb 78                	jmp    c01005b8 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100540:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100547:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010054a:	89 d0                	mov    %edx,%eax
c010054c:	01 c0                	add    %eax,%eax
c010054e:	01 d0                	add    %edx,%eax
c0100550:	c1 e0 02             	shl    $0x2,%eax
c0100553:	89 c2                	mov    %eax,%edx
c0100555:	8b 45 08             	mov    0x8(%ebp),%eax
c0100558:	01 d0                	add    %edx,%eax
c010055a:	8b 40 08             	mov    0x8(%eax),%eax
c010055d:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100560:	73 13                	jae    c0100575 <stab_binsearch+0xb1>
            *region_left = m;
c0100562:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100565:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100568:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010056a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010056d:	83 c0 01             	add    $0x1,%eax
c0100570:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100573:	eb 43                	jmp    c01005b8 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c0100575:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100578:	89 d0                	mov    %edx,%eax
c010057a:	01 c0                	add    %eax,%eax
c010057c:	01 d0                	add    %edx,%eax
c010057e:	c1 e0 02             	shl    $0x2,%eax
c0100581:	89 c2                	mov    %eax,%edx
c0100583:	8b 45 08             	mov    0x8(%ebp),%eax
c0100586:	01 d0                	add    %edx,%eax
c0100588:	8b 40 08             	mov    0x8(%eax),%eax
c010058b:	3b 45 18             	cmp    0x18(%ebp),%eax
c010058e:	76 16                	jbe    c01005a6 <stab_binsearch+0xe2>
            *region_right = m - 1;
c0100590:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100593:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100596:	8b 45 10             	mov    0x10(%ebp),%eax
c0100599:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c010059b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010059e:	83 e8 01             	sub    $0x1,%eax
c01005a1:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01005a4:	eb 12                	jmp    c01005b8 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01005a6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005ac:	89 10                	mov    %edx,(%eax)
            l = m;
c01005ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005b1:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005b4:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01005b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005bb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01005be:	0f 8e 22 ff ff ff    	jle    c01004e6 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01005c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01005c8:	75 0f                	jne    c01005d9 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01005ca:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005cd:	8b 00                	mov    (%eax),%eax
c01005cf:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005d2:	8b 45 10             	mov    0x10(%ebp),%eax
c01005d5:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c01005d7:	eb 3f                	jmp    c0100618 <stab_binsearch+0x154>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01005d9:	8b 45 10             	mov    0x10(%ebp),%eax
c01005dc:	8b 00                	mov    (%eax),%eax
c01005de:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005e1:	eb 04                	jmp    c01005e7 <stab_binsearch+0x123>
c01005e3:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c01005e7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005ea:	8b 00                	mov    (%eax),%eax
c01005ec:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01005ef:	7d 1f                	jge    c0100610 <stab_binsearch+0x14c>
c01005f1:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005f4:	89 d0                	mov    %edx,%eax
c01005f6:	01 c0                	add    %eax,%eax
c01005f8:	01 d0                	add    %edx,%eax
c01005fa:	c1 e0 02             	shl    $0x2,%eax
c01005fd:	89 c2                	mov    %eax,%edx
c01005ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0100602:	01 d0                	add    %edx,%eax
c0100604:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100608:	0f b6 c0             	movzbl %al,%eax
c010060b:	3b 45 14             	cmp    0x14(%ebp),%eax
c010060e:	75 d3                	jne    c01005e3 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0100610:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100613:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100616:	89 10                	mov    %edx,(%eax)
    }
}
c0100618:	90                   	nop
c0100619:	c9                   	leave  
c010061a:	c3                   	ret    

c010061b <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010061b:	55                   	push   %ebp
c010061c:	89 e5                	mov    %esp,%ebp
c010061e:	83 ec 38             	sub    $0x38,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100621:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100624:	c7 00 98 95 10 c0    	movl   $0xc0109598,(%eax)
    info->eip_line = 0;
c010062a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010062d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100634:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100637:	c7 40 08 98 95 10 c0 	movl   $0xc0109598,0x8(%eax)
    info->eip_fn_namelen = 9;
c010063e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100641:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100648:	8b 45 0c             	mov    0xc(%ebp),%eax
c010064b:	8b 55 08             	mov    0x8(%ebp),%edx
c010064e:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100651:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100654:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c010065b:	c7 45 f4 6c b7 10 c0 	movl   $0xc010b76c,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100662:	c7 45 f0 a0 cd 11 c0 	movl   $0xc011cda0,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100669:	c7 45 ec a1 cd 11 c0 	movl   $0xc011cda1,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100670:	c7 45 e8 cd 15 12 c0 	movl   $0xc01215cd,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0100677:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010067a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010067d:	76 0d                	jbe    c010068c <debuginfo_eip+0x71>
c010067f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100682:	83 e8 01             	sub    $0x1,%eax
c0100685:	0f b6 00             	movzbl (%eax),%eax
c0100688:	84 c0                	test   %al,%al
c010068a:	74 0a                	je     c0100696 <debuginfo_eip+0x7b>
        return -1;
c010068c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100691:	e9 91 02 00 00       	jmp    c0100927 <debuginfo_eip+0x30c>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c0100696:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c010069d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01006a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006a3:	29 c2                	sub    %eax,%edx
c01006a5:	89 d0                	mov    %edx,%eax
c01006a7:	c1 f8 02             	sar    $0x2,%eax
c01006aa:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006b0:	83 e8 01             	sub    $0x1,%eax
c01006b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006b6:	ff 75 08             	pushl  0x8(%ebp)
c01006b9:	6a 64                	push   $0x64
c01006bb:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01006be:	50                   	push   %eax
c01006bf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01006c2:	50                   	push   %eax
c01006c3:	ff 75 f4             	pushl  -0xc(%ebp)
c01006c6:	e8 f9 fd ff ff       	call   c01004c4 <stab_binsearch>
c01006cb:	83 c4 14             	add    $0x14,%esp
    if (lfile == 0)
c01006ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006d1:	85 c0                	test   %eax,%eax
c01006d3:	75 0a                	jne    c01006df <debuginfo_eip+0xc4>
        return -1;
c01006d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006da:	e9 48 02 00 00       	jmp    c0100927 <debuginfo_eip+0x30c>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01006df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006e2:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01006e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01006eb:	ff 75 08             	pushl  0x8(%ebp)
c01006ee:	6a 24                	push   $0x24
c01006f0:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01006f3:	50                   	push   %eax
c01006f4:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01006f7:	50                   	push   %eax
c01006f8:	ff 75 f4             	pushl  -0xc(%ebp)
c01006fb:	e8 c4 fd ff ff       	call   c01004c4 <stab_binsearch>
c0100700:	83 c4 14             	add    $0x14,%esp

    if (lfun <= rfun) {
c0100703:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100706:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100709:	39 c2                	cmp    %eax,%edx
c010070b:	7f 7c                	jg     c0100789 <debuginfo_eip+0x16e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c010070d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100710:	89 c2                	mov    %eax,%edx
c0100712:	89 d0                	mov    %edx,%eax
c0100714:	01 c0                	add    %eax,%eax
c0100716:	01 d0                	add    %edx,%eax
c0100718:	c1 e0 02             	shl    $0x2,%eax
c010071b:	89 c2                	mov    %eax,%edx
c010071d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100720:	01 d0                	add    %edx,%eax
c0100722:	8b 00                	mov    (%eax),%eax
c0100724:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100727:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010072a:	29 d1                	sub    %edx,%ecx
c010072c:	89 ca                	mov    %ecx,%edx
c010072e:	39 d0                	cmp    %edx,%eax
c0100730:	73 22                	jae    c0100754 <debuginfo_eip+0x139>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100732:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100735:	89 c2                	mov    %eax,%edx
c0100737:	89 d0                	mov    %edx,%eax
c0100739:	01 c0                	add    %eax,%eax
c010073b:	01 d0                	add    %edx,%eax
c010073d:	c1 e0 02             	shl    $0x2,%eax
c0100740:	89 c2                	mov    %eax,%edx
c0100742:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100745:	01 d0                	add    %edx,%eax
c0100747:	8b 10                	mov    (%eax),%edx
c0100749:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010074c:	01 c2                	add    %eax,%edx
c010074e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100751:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0100754:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100757:	89 c2                	mov    %eax,%edx
c0100759:	89 d0                	mov    %edx,%eax
c010075b:	01 c0                	add    %eax,%eax
c010075d:	01 d0                	add    %edx,%eax
c010075f:	c1 e0 02             	shl    $0x2,%eax
c0100762:	89 c2                	mov    %eax,%edx
c0100764:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100767:	01 d0                	add    %edx,%eax
c0100769:	8b 50 08             	mov    0x8(%eax),%edx
c010076c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010076f:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0100772:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100775:	8b 40 10             	mov    0x10(%eax),%eax
c0100778:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c010077b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010077e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c0100781:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100784:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0100787:	eb 15                	jmp    c010079e <debuginfo_eip+0x183>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c0100789:	8b 45 0c             	mov    0xc(%ebp),%eax
c010078c:	8b 55 08             	mov    0x8(%ebp),%edx
c010078f:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c0100792:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100795:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c0100798:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010079b:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c010079e:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007a1:	8b 40 08             	mov    0x8(%eax),%eax
c01007a4:	83 ec 08             	sub    $0x8,%esp
c01007a7:	6a 3a                	push   $0x3a
c01007a9:	50                   	push   %eax
c01007aa:	e8 cb 82 00 00       	call   c0108a7a <strfind>
c01007af:	83 c4 10             	add    $0x10,%esp
c01007b2:	89 c2                	mov    %eax,%edx
c01007b4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007b7:	8b 40 08             	mov    0x8(%eax),%eax
c01007ba:	29 c2                	sub    %eax,%edx
c01007bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007bf:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01007c2:	83 ec 0c             	sub    $0xc,%esp
c01007c5:	ff 75 08             	pushl  0x8(%ebp)
c01007c8:	6a 44                	push   $0x44
c01007ca:	8d 45 d0             	lea    -0x30(%ebp),%eax
c01007cd:	50                   	push   %eax
c01007ce:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01007d1:	50                   	push   %eax
c01007d2:	ff 75 f4             	pushl  -0xc(%ebp)
c01007d5:	e8 ea fc ff ff       	call   c01004c4 <stab_binsearch>
c01007da:	83 c4 20             	add    $0x20,%esp
    if (lline <= rline) {
c01007dd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007e0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007e3:	39 c2                	cmp    %eax,%edx
c01007e5:	7f 24                	jg     c010080b <debuginfo_eip+0x1f0>
        info->eip_line = stabs[rline].n_desc;
c01007e7:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007ea:	89 c2                	mov    %eax,%edx
c01007ec:	89 d0                	mov    %edx,%eax
c01007ee:	01 c0                	add    %eax,%eax
c01007f0:	01 d0                	add    %edx,%eax
c01007f2:	c1 e0 02             	shl    $0x2,%eax
c01007f5:	89 c2                	mov    %eax,%edx
c01007f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007fa:	01 d0                	add    %edx,%eax
c01007fc:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100800:	0f b7 d0             	movzwl %ax,%edx
c0100803:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100806:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100809:	eb 13                	jmp    c010081e <debuginfo_eip+0x203>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c010080b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100810:	e9 12 01 00 00       	jmp    c0100927 <debuginfo_eip+0x30c>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100815:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100818:	83 e8 01             	sub    $0x1,%eax
c010081b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010081e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100821:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100824:	39 c2                	cmp    %eax,%edx
c0100826:	7c 56                	jl     c010087e <debuginfo_eip+0x263>
           && stabs[lline].n_type != N_SOL
c0100828:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010082b:	89 c2                	mov    %eax,%edx
c010082d:	89 d0                	mov    %edx,%eax
c010082f:	01 c0                	add    %eax,%eax
c0100831:	01 d0                	add    %edx,%eax
c0100833:	c1 e0 02             	shl    $0x2,%eax
c0100836:	89 c2                	mov    %eax,%edx
c0100838:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010083b:	01 d0                	add    %edx,%eax
c010083d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100841:	3c 84                	cmp    $0x84,%al
c0100843:	74 39                	je     c010087e <debuginfo_eip+0x263>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100845:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100848:	89 c2                	mov    %eax,%edx
c010084a:	89 d0                	mov    %edx,%eax
c010084c:	01 c0                	add    %eax,%eax
c010084e:	01 d0                	add    %edx,%eax
c0100850:	c1 e0 02             	shl    $0x2,%eax
c0100853:	89 c2                	mov    %eax,%edx
c0100855:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100858:	01 d0                	add    %edx,%eax
c010085a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010085e:	3c 64                	cmp    $0x64,%al
c0100860:	75 b3                	jne    c0100815 <debuginfo_eip+0x1fa>
c0100862:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100865:	89 c2                	mov    %eax,%edx
c0100867:	89 d0                	mov    %edx,%eax
c0100869:	01 c0                	add    %eax,%eax
c010086b:	01 d0                	add    %edx,%eax
c010086d:	c1 e0 02             	shl    $0x2,%eax
c0100870:	89 c2                	mov    %eax,%edx
c0100872:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100875:	01 d0                	add    %edx,%eax
c0100877:	8b 40 08             	mov    0x8(%eax),%eax
c010087a:	85 c0                	test   %eax,%eax
c010087c:	74 97                	je     c0100815 <debuginfo_eip+0x1fa>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c010087e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100881:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100884:	39 c2                	cmp    %eax,%edx
c0100886:	7c 46                	jl     c01008ce <debuginfo_eip+0x2b3>
c0100888:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010088b:	89 c2                	mov    %eax,%edx
c010088d:	89 d0                	mov    %edx,%eax
c010088f:	01 c0                	add    %eax,%eax
c0100891:	01 d0                	add    %edx,%eax
c0100893:	c1 e0 02             	shl    $0x2,%eax
c0100896:	89 c2                	mov    %eax,%edx
c0100898:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010089b:	01 d0                	add    %edx,%eax
c010089d:	8b 00                	mov    (%eax),%eax
c010089f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01008a2:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01008a5:	29 d1                	sub    %edx,%ecx
c01008a7:	89 ca                	mov    %ecx,%edx
c01008a9:	39 d0                	cmp    %edx,%eax
c01008ab:	73 21                	jae    c01008ce <debuginfo_eip+0x2b3>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01008ad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008b0:	89 c2                	mov    %eax,%edx
c01008b2:	89 d0                	mov    %edx,%eax
c01008b4:	01 c0                	add    %eax,%eax
c01008b6:	01 d0                	add    %edx,%eax
c01008b8:	c1 e0 02             	shl    $0x2,%eax
c01008bb:	89 c2                	mov    %eax,%edx
c01008bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008c0:	01 d0                	add    %edx,%eax
c01008c2:	8b 10                	mov    (%eax),%edx
c01008c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008c7:	01 c2                	add    %eax,%edx
c01008c9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008cc:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01008ce:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01008d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008d4:	39 c2                	cmp    %eax,%edx
c01008d6:	7d 4a                	jge    c0100922 <debuginfo_eip+0x307>
        for (lline = lfun + 1;
c01008d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008db:	83 c0 01             	add    $0x1,%eax
c01008de:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01008e1:	eb 18                	jmp    c01008fb <debuginfo_eip+0x2e0>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c01008e3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008e6:	8b 40 14             	mov    0x14(%eax),%eax
c01008e9:	8d 50 01             	lea    0x1(%eax),%edx
c01008ec:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008ef:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c01008f2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008f5:	83 c0 01             	add    $0x1,%eax
c01008f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c01008fb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01008fe:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0100901:	39 c2                	cmp    %eax,%edx
c0100903:	7d 1d                	jge    c0100922 <debuginfo_eip+0x307>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100905:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100908:	89 c2                	mov    %eax,%edx
c010090a:	89 d0                	mov    %edx,%eax
c010090c:	01 c0                	add    %eax,%eax
c010090e:	01 d0                	add    %edx,%eax
c0100910:	c1 e0 02             	shl    $0x2,%eax
c0100913:	89 c2                	mov    %eax,%edx
c0100915:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100918:	01 d0                	add    %edx,%eax
c010091a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010091e:	3c a0                	cmp    $0xa0,%al
c0100920:	74 c1                	je     c01008e3 <debuginfo_eip+0x2c8>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100922:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100927:	c9                   	leave  
c0100928:	c3                   	ret    

c0100929 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100929:	55                   	push   %ebp
c010092a:	89 e5                	mov    %esp,%ebp
c010092c:	83 ec 08             	sub    $0x8,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c010092f:	83 ec 0c             	sub    $0xc,%esp
c0100932:	68 a2 95 10 c0       	push   $0xc01095a2
c0100937:	e8 4e f9 ff ff       	call   c010028a <cprintf>
c010093c:	83 c4 10             	add    $0x10,%esp
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010093f:	83 ec 08             	sub    $0x8,%esp
c0100942:	68 36 00 10 c0       	push   $0xc0100036
c0100947:	68 bb 95 10 c0       	push   $0xc01095bb
c010094c:	e8 39 f9 ff ff       	call   c010028a <cprintf>
c0100951:	83 c4 10             	add    $0x10,%esp
    cprintf("  etext  0x%08x (phys)\n", etext);
c0100954:	83 ec 08             	sub    $0x8,%esp
c0100957:	68 9a 94 10 c0       	push   $0xc010949a
c010095c:	68 d3 95 10 c0       	push   $0xc01095d3
c0100961:	e8 24 f9 ff ff       	call   c010028a <cprintf>
c0100966:	83 c4 10             	add    $0x10,%esp
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100969:	83 ec 08             	sub    $0x8,%esp
c010096c:	68 00 70 12 c0       	push   $0xc0127000
c0100971:	68 eb 95 10 c0       	push   $0xc01095eb
c0100976:	e8 0f f9 ff ff       	call   c010028a <cprintf>
c010097b:	83 c4 10             	add    $0x10,%esp
    cprintf("  end    0x%08x (phys)\n", end);
c010097e:	83 ec 08             	sub    $0x8,%esp
c0100981:	68 64 a1 12 c0       	push   $0xc012a164
c0100986:	68 03 96 10 c0       	push   $0xc0109603
c010098b:	e8 fa f8 ff ff       	call   c010028a <cprintf>
c0100990:	83 c4 10             	add    $0x10,%esp
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c0100993:	b8 64 a1 12 c0       	mov    $0xc012a164,%eax
c0100998:	05 ff 03 00 00       	add    $0x3ff,%eax
c010099d:	ba 36 00 10 c0       	mov    $0xc0100036,%edx
c01009a2:	29 d0                	sub    %edx,%eax
c01009a4:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009aa:	85 c0                	test   %eax,%eax
c01009ac:	0f 48 c2             	cmovs  %edx,%eax
c01009af:	c1 f8 0a             	sar    $0xa,%eax
c01009b2:	83 ec 08             	sub    $0x8,%esp
c01009b5:	50                   	push   %eax
c01009b6:	68 1c 96 10 c0       	push   $0xc010961c
c01009bb:	e8 ca f8 ff ff       	call   c010028a <cprintf>
c01009c0:	83 c4 10             	add    $0x10,%esp
}
c01009c3:	90                   	nop
c01009c4:	c9                   	leave  
c01009c5:	c3                   	ret    

c01009c6 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c01009c6:	55                   	push   %ebp
c01009c7:	89 e5                	mov    %esp,%ebp
c01009c9:	81 ec 28 01 00 00    	sub    $0x128,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c01009cf:	83 ec 08             	sub    $0x8,%esp
c01009d2:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01009d5:	50                   	push   %eax
c01009d6:	ff 75 08             	pushl  0x8(%ebp)
c01009d9:	e8 3d fc ff ff       	call   c010061b <debuginfo_eip>
c01009de:	83 c4 10             	add    $0x10,%esp
c01009e1:	85 c0                	test   %eax,%eax
c01009e3:	74 15                	je     c01009fa <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c01009e5:	83 ec 08             	sub    $0x8,%esp
c01009e8:	ff 75 08             	pushl  0x8(%ebp)
c01009eb:	68 46 96 10 c0       	push   $0xc0109646
c01009f0:	e8 95 f8 ff ff       	call   c010028a <cprintf>
c01009f5:	83 c4 10             	add    $0x10,%esp
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c01009f8:	eb 65                	jmp    c0100a5f <print_debuginfo+0x99>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c01009fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a01:	eb 1c                	jmp    c0100a1f <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c0100a03:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a09:	01 d0                	add    %edx,%eax
c0100a0b:	0f b6 00             	movzbl (%eax),%eax
c0100a0e:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a14:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a17:	01 ca                	add    %ecx,%edx
c0100a19:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a1b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100a1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a22:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100a25:	7f dc                	jg     c0100a03 <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100a27:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a30:	01 d0                	add    %edx,%eax
c0100a32:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100a35:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a38:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a3b:	89 d1                	mov    %edx,%ecx
c0100a3d:	29 c1                	sub    %eax,%ecx
c0100a3f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a42:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a45:	83 ec 0c             	sub    $0xc,%esp
c0100a48:	51                   	push   %ecx
c0100a49:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a4f:	51                   	push   %ecx
c0100a50:	52                   	push   %edx
c0100a51:	50                   	push   %eax
c0100a52:	68 62 96 10 c0       	push   $0xc0109662
c0100a57:	e8 2e f8 ff ff       	call   c010028a <cprintf>
c0100a5c:	83 c4 20             	add    $0x20,%esp
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a5f:	90                   	nop
c0100a60:	c9                   	leave  
c0100a61:	c3                   	ret    

c0100a62 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a62:	55                   	push   %ebp
c0100a63:	89 e5                	mov    %esp,%ebp
c0100a65:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a68:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a6b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a6e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100a71:	c9                   	leave  
c0100a72:	c3                   	ret    

c0100a73 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100a73:	55                   	push   %ebp
c0100a74:	89 e5                	mov    %esp,%ebp
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
}
c0100a76:	90                   	nop
c0100a77:	5d                   	pop    %ebp
c0100a78:	c3                   	ret    

c0100a79 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100a79:	55                   	push   %ebp
c0100a7a:	89 e5                	mov    %esp,%ebp
c0100a7c:	83 ec 18             	sub    $0x18,%esp
    int argc = 0;
c0100a7f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a86:	eb 0c                	jmp    c0100a94 <parse+0x1b>
            *buf ++ = '\0';
c0100a88:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a8b:	8d 50 01             	lea    0x1(%eax),%edx
c0100a8e:	89 55 08             	mov    %edx,0x8(%ebp)
c0100a91:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a94:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a97:	0f b6 00             	movzbl (%eax),%eax
c0100a9a:	84 c0                	test   %al,%al
c0100a9c:	74 1e                	je     c0100abc <parse+0x43>
c0100a9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aa1:	0f b6 00             	movzbl (%eax),%eax
c0100aa4:	0f be c0             	movsbl %al,%eax
c0100aa7:	83 ec 08             	sub    $0x8,%esp
c0100aaa:	50                   	push   %eax
c0100aab:	68 f4 96 10 c0       	push   $0xc01096f4
c0100ab0:	e8 92 7f 00 00       	call   c0108a47 <strchr>
c0100ab5:	83 c4 10             	add    $0x10,%esp
c0100ab8:	85 c0                	test   %eax,%eax
c0100aba:	75 cc                	jne    c0100a88 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100abc:	8b 45 08             	mov    0x8(%ebp),%eax
c0100abf:	0f b6 00             	movzbl (%eax),%eax
c0100ac2:	84 c0                	test   %al,%al
c0100ac4:	74 69                	je     c0100b2f <parse+0xb6>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100ac6:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100aca:	75 12                	jne    c0100ade <parse+0x65>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100acc:	83 ec 08             	sub    $0x8,%esp
c0100acf:	6a 10                	push   $0x10
c0100ad1:	68 f9 96 10 c0       	push   $0xc01096f9
c0100ad6:	e8 af f7 ff ff       	call   c010028a <cprintf>
c0100adb:	83 c4 10             	add    $0x10,%esp
        }
        argv[argc ++] = buf;
c0100ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ae1:	8d 50 01             	lea    0x1(%eax),%edx
c0100ae4:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100ae7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100aee:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100af1:	01 c2                	add    %eax,%edx
c0100af3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100af6:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100af8:	eb 04                	jmp    c0100afe <parse+0x85>
            buf ++;
c0100afa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100afe:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b01:	0f b6 00             	movzbl (%eax),%eax
c0100b04:	84 c0                	test   %al,%al
c0100b06:	0f 84 7a ff ff ff    	je     c0100a86 <parse+0xd>
c0100b0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b0f:	0f b6 00             	movzbl (%eax),%eax
c0100b12:	0f be c0             	movsbl %al,%eax
c0100b15:	83 ec 08             	sub    $0x8,%esp
c0100b18:	50                   	push   %eax
c0100b19:	68 f4 96 10 c0       	push   $0xc01096f4
c0100b1e:	e8 24 7f 00 00       	call   c0108a47 <strchr>
c0100b23:	83 c4 10             	add    $0x10,%esp
c0100b26:	85 c0                	test   %eax,%eax
c0100b28:	74 d0                	je     c0100afa <parse+0x81>
            buf ++;
        }
    }
c0100b2a:	e9 57 ff ff ff       	jmp    c0100a86 <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
c0100b2f:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b33:	c9                   	leave  
c0100b34:	c3                   	ret    

c0100b35 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b35:	55                   	push   %ebp
c0100b36:	89 e5                	mov    %esp,%ebp
c0100b38:	83 ec 58             	sub    $0x58,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b3b:	83 ec 08             	sub    $0x8,%esp
c0100b3e:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b41:	50                   	push   %eax
c0100b42:	ff 75 08             	pushl  0x8(%ebp)
c0100b45:	e8 2f ff ff ff       	call   c0100a79 <parse>
c0100b4a:	83 c4 10             	add    $0x10,%esp
c0100b4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100b50:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b54:	75 0a                	jne    c0100b60 <runcmd+0x2b>
        return 0;
c0100b56:	b8 00 00 00 00       	mov    $0x0,%eax
c0100b5b:	e9 83 00 00 00       	jmp    c0100be3 <runcmd+0xae>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b60:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b67:	eb 59                	jmp    c0100bc2 <runcmd+0x8d>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100b69:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100b6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b6f:	89 d0                	mov    %edx,%eax
c0100b71:	01 c0                	add    %eax,%eax
c0100b73:	01 d0                	add    %edx,%eax
c0100b75:	c1 e0 02             	shl    $0x2,%eax
c0100b78:	05 00 40 12 c0       	add    $0xc0124000,%eax
c0100b7d:	8b 00                	mov    (%eax),%eax
c0100b7f:	83 ec 08             	sub    $0x8,%esp
c0100b82:	51                   	push   %ecx
c0100b83:	50                   	push   %eax
c0100b84:	e8 1e 7e 00 00       	call   c01089a7 <strcmp>
c0100b89:	83 c4 10             	add    $0x10,%esp
c0100b8c:	85 c0                	test   %eax,%eax
c0100b8e:	75 2e                	jne    c0100bbe <runcmd+0x89>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100b90:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b93:	89 d0                	mov    %edx,%eax
c0100b95:	01 c0                	add    %eax,%eax
c0100b97:	01 d0                	add    %edx,%eax
c0100b99:	c1 e0 02             	shl    $0x2,%eax
c0100b9c:	05 08 40 12 c0       	add    $0xc0124008,%eax
c0100ba1:	8b 10                	mov    (%eax),%edx
c0100ba3:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100ba6:	83 c0 04             	add    $0x4,%eax
c0100ba9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100bac:	83 e9 01             	sub    $0x1,%ecx
c0100baf:	83 ec 04             	sub    $0x4,%esp
c0100bb2:	ff 75 0c             	pushl  0xc(%ebp)
c0100bb5:	50                   	push   %eax
c0100bb6:	51                   	push   %ecx
c0100bb7:	ff d2                	call   *%edx
c0100bb9:	83 c4 10             	add    $0x10,%esp
c0100bbc:	eb 25                	jmp    c0100be3 <runcmd+0xae>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bbe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bc5:	83 f8 02             	cmp    $0x2,%eax
c0100bc8:	76 9f                	jbe    c0100b69 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100bca:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100bcd:	83 ec 08             	sub    $0x8,%esp
c0100bd0:	50                   	push   %eax
c0100bd1:	68 17 97 10 c0       	push   $0xc0109717
c0100bd6:	e8 af f6 ff ff       	call   c010028a <cprintf>
c0100bdb:	83 c4 10             	add    $0x10,%esp
    return 0;
c0100bde:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100be3:	c9                   	leave  
c0100be4:	c3                   	ret    

c0100be5 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100be5:	55                   	push   %ebp
c0100be6:	89 e5                	mov    %esp,%ebp
c0100be8:	83 ec 18             	sub    $0x18,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100beb:	83 ec 0c             	sub    $0xc,%esp
c0100bee:	68 30 97 10 c0       	push   $0xc0109730
c0100bf3:	e8 92 f6 ff ff       	call   c010028a <cprintf>
c0100bf8:	83 c4 10             	add    $0x10,%esp
    cprintf("Type 'help' for a list of commands.\n");
c0100bfb:	83 ec 0c             	sub    $0xc,%esp
c0100bfe:	68 58 97 10 c0       	push   $0xc0109758
c0100c03:	e8 82 f6 ff ff       	call   c010028a <cprintf>
c0100c08:	83 c4 10             	add    $0x10,%esp

    if (tf != NULL) {
c0100c0b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c0f:	74 0e                	je     c0100c1f <kmonitor+0x3a>
        print_trapframe(tf);
c0100c11:	83 ec 0c             	sub    $0xc,%esp
c0100c14:	ff 75 08             	pushl  0x8(%ebp)
c0100c17:	e8 52 15 00 00       	call   c010216e <print_trapframe>
c0100c1c:	83 c4 10             	add    $0x10,%esp
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c1f:	83 ec 0c             	sub    $0xc,%esp
c0100c22:	68 7d 97 10 c0       	push   $0xc010977d
c0100c27:	e8 02 f7 ff ff       	call   c010032e <readline>
c0100c2c:	83 c4 10             	add    $0x10,%esp
c0100c2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c36:	74 e7                	je     c0100c1f <kmonitor+0x3a>
            if (runcmd(buf, tf) < 0) {
c0100c38:	83 ec 08             	sub    $0x8,%esp
c0100c3b:	ff 75 08             	pushl  0x8(%ebp)
c0100c3e:	ff 75 f4             	pushl  -0xc(%ebp)
c0100c41:	e8 ef fe ff ff       	call   c0100b35 <runcmd>
c0100c46:	83 c4 10             	add    $0x10,%esp
c0100c49:	85 c0                	test   %eax,%eax
c0100c4b:	78 02                	js     c0100c4f <kmonitor+0x6a>
                break;
            }
        }
    }
c0100c4d:	eb d0                	jmp    c0100c1f <kmonitor+0x3a>

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
            if (runcmd(buf, tf) < 0) {
                break;
c0100c4f:	90                   	nop
            }
        }
    }
}
c0100c50:	90                   	nop
c0100c51:	c9                   	leave  
c0100c52:	c3                   	ret    

c0100c53 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100c53:	55                   	push   %ebp
c0100c54:	89 e5                	mov    %esp,%ebp
c0100c56:	83 ec 18             	sub    $0x18,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c60:	eb 3c                	jmp    c0100c9e <mon_help+0x4b>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100c62:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c65:	89 d0                	mov    %edx,%eax
c0100c67:	01 c0                	add    %eax,%eax
c0100c69:	01 d0                	add    %edx,%eax
c0100c6b:	c1 e0 02             	shl    $0x2,%eax
c0100c6e:	05 04 40 12 c0       	add    $0xc0124004,%eax
c0100c73:	8b 08                	mov    (%eax),%ecx
c0100c75:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c78:	89 d0                	mov    %edx,%eax
c0100c7a:	01 c0                	add    %eax,%eax
c0100c7c:	01 d0                	add    %edx,%eax
c0100c7e:	c1 e0 02             	shl    $0x2,%eax
c0100c81:	05 00 40 12 c0       	add    $0xc0124000,%eax
c0100c86:	8b 00                	mov    (%eax),%eax
c0100c88:	83 ec 04             	sub    $0x4,%esp
c0100c8b:	51                   	push   %ecx
c0100c8c:	50                   	push   %eax
c0100c8d:	68 81 97 10 c0       	push   $0xc0109781
c0100c92:	e8 f3 f5 ff ff       	call   c010028a <cprintf>
c0100c97:	83 c4 10             	add    $0x10,%esp

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c9a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ca1:	83 f8 02             	cmp    $0x2,%eax
c0100ca4:	76 bc                	jbe    c0100c62 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100ca6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cab:	c9                   	leave  
c0100cac:	c3                   	ret    

c0100cad <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100cad:	55                   	push   %ebp
c0100cae:	89 e5                	mov    %esp,%ebp
c0100cb0:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100cb3:	e8 71 fc ff ff       	call   c0100929 <print_kerninfo>
    return 0;
c0100cb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cbd:	c9                   	leave  
c0100cbe:	c3                   	ret    

c0100cbf <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100cbf:	55                   	push   %ebp
c0100cc0:	89 e5                	mov    %esp,%ebp
c0100cc2:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100cc5:	e8 a9 fd ff ff       	call   c0100a73 <print_stackframe>
    return 0;
c0100cca:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ccf:	c9                   	leave  
c0100cd0:	c3                   	ret    

c0100cd1 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0100cd1:	55                   	push   %ebp
c0100cd2:	89 e5                	mov    %esp,%ebp
c0100cd4:	83 ec 14             	sub    $0x14,%esp
c0100cd7:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cda:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0100cde:	90                   	nop
c0100cdf:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0100ce3:	83 c0 07             	add    $0x7,%eax
c0100ce6:	0f b7 c0             	movzwl %ax,%eax
c0100ce9:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ced:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100cf1:	89 c2                	mov    %eax,%edx
c0100cf3:	ec                   	in     (%dx),%al
c0100cf4:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0100cf7:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0100cfb:	0f b6 c0             	movzbl %al,%eax
c0100cfe:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100d01:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100d04:	25 80 00 00 00       	and    $0x80,%eax
c0100d09:	85 c0                	test   %eax,%eax
c0100d0b:	75 d2                	jne    c0100cdf <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0100d0d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0100d11:	74 11                	je     c0100d24 <ide_wait_ready+0x53>
c0100d13:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100d16:	83 e0 21             	and    $0x21,%eax
c0100d19:	85 c0                	test   %eax,%eax
c0100d1b:	74 07                	je     c0100d24 <ide_wait_ready+0x53>
        return -1;
c0100d1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100d22:	eb 05                	jmp    c0100d29 <ide_wait_ready+0x58>
    }
    return 0;
c0100d24:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d29:	c9                   	leave  
c0100d2a:	c3                   	ret    

c0100d2b <ide_init>:

void
ide_init(void) {
c0100d2b:	55                   	push   %ebp
c0100d2c:	89 e5                	mov    %esp,%ebp
c0100d2e:	57                   	push   %edi
c0100d2f:	53                   	push   %ebx
c0100d30:	81 ec 40 02 00 00    	sub    $0x240,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0100d36:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0100d3c:	e9 c1 02 00 00       	jmp    c0101002 <ide_init+0x2d7>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0100d41:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100d45:	c1 e0 03             	shl    $0x3,%eax
c0100d48:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100d4f:	29 c2                	sub    %eax,%edx
c0100d51:	89 d0                	mov    %edx,%eax
c0100d53:	05 40 74 12 c0       	add    $0xc0127440,%eax
c0100d58:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0100d5b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100d5f:	66 d1 e8             	shr    %ax
c0100d62:	0f b7 c0             	movzwl %ax,%eax
c0100d65:	0f b7 04 85 8c 97 10 	movzwl -0x3fef6874(,%eax,4),%eax
c0100d6c:	c0 
c0100d6d:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0100d71:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100d75:	6a 00                	push   $0x0
c0100d77:	50                   	push   %eax
c0100d78:	e8 54 ff ff ff       	call   c0100cd1 <ide_wait_ready>
c0100d7d:	83 c4 08             	add    $0x8,%esp

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0100d80:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100d84:	83 e0 01             	and    $0x1,%eax
c0100d87:	c1 e0 04             	shl    $0x4,%eax
c0100d8a:	83 c8 e0             	or     $0xffffffe0,%eax
c0100d8d:	0f b6 c0             	movzbl %al,%eax
c0100d90:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100d94:	83 c2 06             	add    $0x6,%edx
c0100d97:	0f b7 d2             	movzwl %dx,%edx
c0100d9a:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0100d9e:	88 45 c7             	mov    %al,-0x39(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100da1:	0f b6 45 c7          	movzbl -0x39(%ebp),%eax
c0100da5:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100da9:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100daa:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100dae:	6a 00                	push   $0x0
c0100db0:	50                   	push   %eax
c0100db1:	e8 1b ff ff ff       	call   c0100cd1 <ide_wait_ready>
c0100db6:	83 c4 08             	add    $0x8,%esp

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0100db9:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100dbd:	83 c0 07             	add    $0x7,%eax
c0100dc0:	0f b7 c0             	movzwl %ax,%eax
c0100dc3:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
c0100dc7:	c6 45 c8 ec          	movb   $0xec,-0x38(%ebp)
c0100dcb:	0f b6 45 c8          	movzbl -0x38(%ebp),%eax
c0100dcf:	0f b7 55 e0          	movzwl -0x20(%ebp),%edx
c0100dd3:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100dd4:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100dd8:	6a 00                	push   $0x0
c0100dda:	50                   	push   %eax
c0100ddb:	e8 f1 fe ff ff       	call   c0100cd1 <ide_wait_ready>
c0100de0:	83 c4 08             	add    $0x8,%esp

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0100de3:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100de7:	83 c0 07             	add    $0x7,%eax
c0100dea:	0f b7 c0             	movzwl %ax,%eax
c0100ded:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100df1:	0f b7 45 ca          	movzwl -0x36(%ebp),%eax
c0100df5:	89 c2                	mov    %eax,%edx
c0100df7:	ec                   	in     (%dx),%al
c0100df8:	88 45 c9             	mov    %al,-0x37(%ebp)
    return data;
c0100dfb:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0100dff:	84 c0                	test   %al,%al
c0100e01:	0f 84 ef 01 00 00    	je     c0100ff6 <ide_init+0x2cb>
c0100e07:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e0b:	6a 01                	push   $0x1
c0100e0d:	50                   	push   %eax
c0100e0e:	e8 be fe ff ff       	call   c0100cd1 <ide_wait_ready>
c0100e13:	83 c4 08             	add    $0x8,%esp
c0100e16:	85 c0                	test   %eax,%eax
c0100e18:	0f 85 d8 01 00 00    	jne    c0100ff6 <ide_init+0x2cb>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0100e1e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e22:	c1 e0 03             	shl    $0x3,%eax
c0100e25:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100e2c:	29 c2                	sub    %eax,%edx
c0100e2e:	89 d0                	mov    %edx,%eax
c0100e30:	05 40 74 12 c0       	add    $0xc0127440,%eax
c0100e35:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0100e38:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e3c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0100e3f:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100e45:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0100e48:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0100e4f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100e52:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0100e55:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0100e58:	89 cb                	mov    %ecx,%ebx
c0100e5a:	89 df                	mov    %ebx,%edi
c0100e5c:	89 c1                	mov    %eax,%ecx
c0100e5e:	fc                   	cld    
c0100e5f:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0100e61:	89 c8                	mov    %ecx,%eax
c0100e63:	89 fb                	mov    %edi,%ebx
c0100e65:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0100e68:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c0100e6b:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100e71:	89 45 dc             	mov    %eax,-0x24(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0100e74:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100e77:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0100e7d:	89 45 d8             	mov    %eax,-0x28(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c0100e80:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100e83:	25 00 00 00 04       	and    $0x4000000,%eax
c0100e88:	85 c0                	test   %eax,%eax
c0100e8a:	74 0e                	je     c0100e9a <ide_init+0x16f>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c0100e8c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100e8f:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0100e95:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100e98:	eb 09                	jmp    c0100ea3 <ide_init+0x178>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0100e9a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100e9d:	8b 40 78             	mov    0x78(%eax),%eax
c0100ea0:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c0100ea3:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100ea7:	c1 e0 03             	shl    $0x3,%eax
c0100eaa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100eb1:	29 c2                	sub    %eax,%edx
c0100eb3:	89 d0                	mov    %edx,%eax
c0100eb5:	8d 90 44 74 12 c0    	lea    -0x3fed8bbc(%eax),%edx
c0100ebb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100ebe:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c0100ec0:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100ec4:	c1 e0 03             	shl    $0x3,%eax
c0100ec7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100ece:	29 c2                	sub    %eax,%edx
c0100ed0:	89 d0                	mov    %edx,%eax
c0100ed2:	8d 90 48 74 12 c0    	lea    -0x3fed8bb8(%eax),%edx
c0100ed8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100edb:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c0100edd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100ee0:	83 c0 62             	add    $0x62,%eax
c0100ee3:	0f b7 00             	movzwl (%eax),%eax
c0100ee6:	0f b7 c0             	movzwl %ax,%eax
c0100ee9:	25 00 02 00 00       	and    $0x200,%eax
c0100eee:	85 c0                	test   %eax,%eax
c0100ef0:	75 16                	jne    c0100f08 <ide_init+0x1dd>
c0100ef2:	68 94 97 10 c0       	push   $0xc0109794
c0100ef7:	68 d7 97 10 c0       	push   $0xc01097d7
c0100efc:	6a 7d                	push   $0x7d
c0100efe:	68 ec 97 10 c0       	push   $0xc01097ec
c0100f03:	e8 e8 f4 ff ff       	call   c01003f0 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0100f08:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f0c:	89 c2                	mov    %eax,%edx
c0100f0e:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
c0100f15:	89 c2                	mov    %eax,%edx
c0100f17:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
c0100f1e:	29 d0                	sub    %edx,%eax
c0100f20:	05 40 74 12 c0       	add    $0xc0127440,%eax
c0100f25:	83 c0 0c             	add    $0xc,%eax
c0100f28:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100f2b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100f2e:	83 c0 36             	add    $0x36,%eax
c0100f31:	89 45 d0             	mov    %eax,-0x30(%ebp)
        unsigned int i, length = 40;
c0100f34:	c7 45 cc 28 00 00 00 	movl   $0x28,-0x34(%ebp)
        for (i = 0; i < length; i += 2) {
c0100f3b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100f42:	eb 34                	jmp    c0100f78 <ide_init+0x24d>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0100f44:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100f47:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100f4a:	01 c2                	add    %eax,%edx
c0100f4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100f4f:	8d 48 01             	lea    0x1(%eax),%ecx
c0100f52:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100f55:	01 c8                	add    %ecx,%eax
c0100f57:	0f b6 00             	movzbl (%eax),%eax
c0100f5a:	88 02                	mov    %al,(%edx)
c0100f5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100f5f:	8d 50 01             	lea    0x1(%eax),%edx
c0100f62:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100f65:	01 c2                	add    %eax,%edx
c0100f67:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0100f6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100f6d:	01 c8                	add    %ecx,%eax
c0100f6f:	0f b6 00             	movzbl (%eax),%eax
c0100f72:	88 02                	mov    %al,(%edx)
        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
        unsigned int i, length = 40;
        for (i = 0; i < length; i += 2) {
c0100f74:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0100f78:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100f7b:	3b 45 cc             	cmp    -0x34(%ebp),%eax
c0100f7e:	72 c4                	jb     c0100f44 <ide_init+0x219>
            model[i] = data[i + 1], model[i + 1] = data[i];
        }
        do {
            model[i] = '\0';
c0100f80:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100f83:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100f86:	01 d0                	add    %edx,%eax
c0100f88:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0100f8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100f8e:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100f91:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0100f94:	85 c0                	test   %eax,%eax
c0100f96:	74 0f                	je     c0100fa7 <ide_init+0x27c>
c0100f98:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100f9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100f9e:	01 d0                	add    %edx,%eax
c0100fa0:	0f b6 00             	movzbl (%eax),%eax
c0100fa3:	3c 20                	cmp    $0x20,%al
c0100fa5:	74 d9                	je     c0100f80 <ide_init+0x255>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c0100fa7:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100fab:	89 c2                	mov    %eax,%edx
c0100fad:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
c0100fb4:	89 c2                	mov    %eax,%edx
c0100fb6:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
c0100fbd:	29 d0                	sub    %edx,%eax
c0100fbf:	05 40 74 12 c0       	add    $0xc0127440,%eax
c0100fc4:	8d 48 0c             	lea    0xc(%eax),%ecx
c0100fc7:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100fcb:	c1 e0 03             	shl    $0x3,%eax
c0100fce:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100fd5:	29 c2                	sub    %eax,%edx
c0100fd7:	89 d0                	mov    %edx,%eax
c0100fd9:	05 48 74 12 c0       	add    $0xc0127448,%eax
c0100fde:	8b 10                	mov    (%eax),%edx
c0100fe0:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100fe4:	51                   	push   %ecx
c0100fe5:	52                   	push   %edx
c0100fe6:	50                   	push   %eax
c0100fe7:	68 fe 97 10 c0       	push   $0xc01097fe
c0100fec:	e8 99 f2 ff ff       	call   c010028a <cprintf>
c0100ff1:	83 c4 10             	add    $0x10,%esp
c0100ff4:	eb 01                	jmp    c0100ff7 <ide_init+0x2cc>
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
        ide_wait_ready(iobase, 0);

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
            continue ;
c0100ff6:	90                   	nop

void
ide_init(void) {
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0100ff7:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100ffb:	83 c0 01             	add    $0x1,%eax
c0100ffe:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0101002:	66 83 7d f6 03       	cmpw   $0x3,-0xa(%ebp)
c0101007:	0f 86 34 fd ff ff    	jbe    c0100d41 <ide_init+0x16>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c010100d:	83 ec 0c             	sub    $0xc,%esp
c0101010:	6a 0e                	push   $0xe
c0101012:	e8 8a 0e 00 00       	call   c0101ea1 <pic_enable>
c0101017:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_IDE2);
c010101a:	83 ec 0c             	sub    $0xc,%esp
c010101d:	6a 0f                	push   $0xf
c010101f:	e8 7d 0e 00 00       	call   c0101ea1 <pic_enable>
c0101024:	83 c4 10             	add    $0x10,%esp
}
c0101027:	90                   	nop
c0101028:	8d 65 f8             	lea    -0x8(%ebp),%esp
c010102b:	5b                   	pop    %ebx
c010102c:	5f                   	pop    %edi
c010102d:	5d                   	pop    %ebp
c010102e:	c3                   	ret    

c010102f <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c010102f:	55                   	push   %ebp
c0101030:	89 e5                	mov    %esp,%ebp
c0101032:	83 ec 04             	sub    $0x4,%esp
c0101035:	8b 45 08             	mov    0x8(%ebp),%eax
c0101038:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c010103c:	66 83 7d fc 03       	cmpw   $0x3,-0x4(%ebp)
c0101041:	77 25                	ja     c0101068 <ide_device_valid+0x39>
c0101043:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101047:	c1 e0 03             	shl    $0x3,%eax
c010104a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101051:	29 c2                	sub    %eax,%edx
c0101053:	89 d0                	mov    %edx,%eax
c0101055:	05 40 74 12 c0       	add    $0xc0127440,%eax
c010105a:	0f b6 00             	movzbl (%eax),%eax
c010105d:	84 c0                	test   %al,%al
c010105f:	74 07                	je     c0101068 <ide_device_valid+0x39>
c0101061:	b8 01 00 00 00       	mov    $0x1,%eax
c0101066:	eb 05                	jmp    c010106d <ide_device_valid+0x3e>
c0101068:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010106d:	c9                   	leave  
c010106e:	c3                   	ret    

c010106f <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c010106f:	55                   	push   %ebp
c0101070:	89 e5                	mov    %esp,%ebp
c0101072:	83 ec 04             	sub    $0x4,%esp
c0101075:	8b 45 08             	mov    0x8(%ebp),%eax
c0101078:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c010107c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101080:	50                   	push   %eax
c0101081:	e8 a9 ff ff ff       	call   c010102f <ide_device_valid>
c0101086:	83 c4 04             	add    $0x4,%esp
c0101089:	85 c0                	test   %eax,%eax
c010108b:	74 1b                	je     c01010a8 <ide_device_size+0x39>
        return ide_devices[ideno].size;
c010108d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101091:	c1 e0 03             	shl    $0x3,%eax
c0101094:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010109b:	29 c2                	sub    %eax,%edx
c010109d:	89 d0                	mov    %edx,%eax
c010109f:	05 48 74 12 c0       	add    $0xc0127448,%eax
c01010a4:	8b 00                	mov    (%eax),%eax
c01010a6:	eb 05                	jmp    c01010ad <ide_device_size+0x3e>
    }
    return 0;
c01010a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01010ad:	c9                   	leave  
c01010ae:	c3                   	ret    

c01010af <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c01010af:	55                   	push   %ebp
c01010b0:	89 e5                	mov    %esp,%ebp
c01010b2:	57                   	push   %edi
c01010b3:	53                   	push   %ebx
c01010b4:	83 ec 40             	sub    $0x40,%esp
c01010b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01010ba:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01010be:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c01010c5:	77 25                	ja     c01010ec <ide_read_secs+0x3d>
c01010c7:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c01010cc:	77 1e                	ja     c01010ec <ide_read_secs+0x3d>
c01010ce:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01010d2:	c1 e0 03             	shl    $0x3,%eax
c01010d5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01010dc:	29 c2                	sub    %eax,%edx
c01010de:	89 d0                	mov    %edx,%eax
c01010e0:	05 40 74 12 c0       	add    $0xc0127440,%eax
c01010e5:	0f b6 00             	movzbl (%eax),%eax
c01010e8:	84 c0                	test   %al,%al
c01010ea:	75 19                	jne    c0101105 <ide_read_secs+0x56>
c01010ec:	68 1c 98 10 c0       	push   $0xc010981c
c01010f1:	68 d7 97 10 c0       	push   $0xc01097d7
c01010f6:	68 9f 00 00 00       	push   $0x9f
c01010fb:	68 ec 97 10 c0       	push   $0xc01097ec
c0101100:	e8 eb f2 ff ff       	call   c01003f0 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101105:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c010110c:	77 0f                	ja     c010111d <ide_read_secs+0x6e>
c010110e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101111:	8b 45 14             	mov    0x14(%ebp),%eax
c0101114:	01 d0                	add    %edx,%eax
c0101116:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c010111b:	76 19                	jbe    c0101136 <ide_read_secs+0x87>
c010111d:	68 44 98 10 c0       	push   $0xc0109844
c0101122:	68 d7 97 10 c0       	push   $0xc01097d7
c0101127:	68 a0 00 00 00       	push   $0xa0
c010112c:	68 ec 97 10 c0       	push   $0xc01097ec
c0101131:	e8 ba f2 ff ff       	call   c01003f0 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101136:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010113a:	66 d1 e8             	shr    %ax
c010113d:	0f b7 c0             	movzwl %ax,%eax
c0101140:	0f b7 04 85 8c 97 10 	movzwl -0x3fef6874(,%eax,4),%eax
c0101147:	c0 
c0101148:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010114c:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101150:	66 d1 e8             	shr    %ax
c0101153:	0f b7 c0             	movzwl %ax,%eax
c0101156:	0f b7 04 85 8e 97 10 	movzwl -0x3fef6872(,%eax,4),%eax
c010115d:	c0 
c010115e:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101162:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101166:	83 ec 08             	sub    $0x8,%esp
c0101169:	6a 00                	push   $0x0
c010116b:	50                   	push   %eax
c010116c:	e8 60 fb ff ff       	call   c0100cd1 <ide_wait_ready>
c0101171:	83 c4 10             	add    $0x10,%esp

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101174:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101178:	83 c0 02             	add    $0x2,%eax
c010117b:	0f b7 c0             	movzwl %ax,%eax
c010117e:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0101182:	c6 45 d7 00          	movb   $0x0,-0x29(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101186:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c010118a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010118e:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c010118f:	8b 45 14             	mov    0x14(%ebp),%eax
c0101192:	0f b6 c0             	movzbl %al,%eax
c0101195:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101199:	83 c2 02             	add    $0x2,%edx
c010119c:	0f b7 d2             	movzwl %dx,%edx
c010119f:	66 89 55 e8          	mov    %dx,-0x18(%ebp)
c01011a3:	88 45 d8             	mov    %al,-0x28(%ebp)
c01011a6:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c01011aa:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01011ae:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c01011af:	8b 45 0c             	mov    0xc(%ebp),%eax
c01011b2:	0f b6 c0             	movzbl %al,%eax
c01011b5:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01011b9:	83 c2 03             	add    $0x3,%edx
c01011bc:	0f b7 d2             	movzwl %dx,%edx
c01011bf:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01011c3:	88 45 d9             	mov    %al,-0x27(%ebp)
c01011c6:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01011ca:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01011ce:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c01011cf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01011d2:	c1 e8 08             	shr    $0x8,%eax
c01011d5:	0f b6 c0             	movzbl %al,%eax
c01011d8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01011dc:	83 c2 04             	add    $0x4,%edx
c01011df:	0f b7 d2             	movzwl %dx,%edx
c01011e2:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
c01011e6:	88 45 da             	mov    %al,-0x26(%ebp)
c01011e9:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c01011ed:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
c01011f1:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c01011f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01011f5:	c1 e8 10             	shr    $0x10,%eax
c01011f8:	0f b6 c0             	movzbl %al,%eax
c01011fb:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01011ff:	83 c2 05             	add    $0x5,%edx
c0101202:	0f b7 d2             	movzwl %dx,%edx
c0101205:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101209:	88 45 db             	mov    %al,-0x25(%ebp)
c010120c:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0101210:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101214:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101215:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101219:	83 e0 01             	and    $0x1,%eax
c010121c:	c1 e0 04             	shl    $0x4,%eax
c010121f:	89 c2                	mov    %eax,%edx
c0101221:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101224:	c1 e8 18             	shr    $0x18,%eax
c0101227:	83 e0 0f             	and    $0xf,%eax
c010122a:	09 d0                	or     %edx,%eax
c010122c:	83 c8 e0             	or     $0xffffffe0,%eax
c010122f:	0f b6 c0             	movzbl %al,%eax
c0101232:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101236:	83 c2 06             	add    $0x6,%edx
c0101239:	0f b7 d2             	movzwl %dx,%edx
c010123c:	66 89 55 e0          	mov    %dx,-0x20(%ebp)
c0101240:	88 45 dc             	mov    %al,-0x24(%ebp)
c0101243:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0101247:	0f b7 55 e0          	movzwl -0x20(%ebp),%edx
c010124b:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c010124c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101250:	83 c0 07             	add    $0x7,%eax
c0101253:	0f b7 c0             	movzwl %ax,%eax
c0101256:	66 89 45 de          	mov    %ax,-0x22(%ebp)
c010125a:	c6 45 dd 20          	movb   $0x20,-0x23(%ebp)
c010125e:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101262:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101266:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101267:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c010126e:	eb 56                	jmp    c01012c6 <ide_read_secs+0x217>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101270:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101274:	83 ec 08             	sub    $0x8,%esp
c0101277:	6a 01                	push   $0x1
c0101279:	50                   	push   %eax
c010127a:	e8 52 fa ff ff       	call   c0100cd1 <ide_wait_ready>
c010127f:	83 c4 10             	add    $0x10,%esp
c0101282:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101285:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101289:	75 43                	jne    c01012ce <ide_read_secs+0x21f>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c010128b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010128f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0101292:	8b 45 10             	mov    0x10(%ebp),%eax
c0101295:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101298:	c7 45 cc 80 00 00 00 	movl   $0x80,-0x34(%ebp)
    return data;
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c010129f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01012a2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c01012a5:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01012a8:	89 cb                	mov    %ecx,%ebx
c01012aa:	89 df                	mov    %ebx,%edi
c01012ac:	89 c1                	mov    %eax,%ecx
c01012ae:	fc                   	cld    
c01012af:	f2 6d                	repnz insl (%dx),%es:(%edi)
c01012b1:	89 c8                	mov    %ecx,%eax
c01012b3:	89 fb                	mov    %edi,%ebx
c01012b5:	89 5d d0             	mov    %ebx,-0x30(%ebp)
c01012b8:	89 45 cc             	mov    %eax,-0x34(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);

    int ret = 0;
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c01012bb:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c01012bf:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01012c6:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01012ca:	75 a4                	jne    c0101270 <ide_read_secs+0x1c1>
c01012cc:	eb 01                	jmp    c01012cf <ide_read_secs+0x220>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
            goto out;
c01012ce:	90                   	nop
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c01012cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01012d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
c01012d5:	5b                   	pop    %ebx
c01012d6:	5f                   	pop    %edi
c01012d7:	5d                   	pop    %ebp
c01012d8:	c3                   	ret    

c01012d9 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c01012d9:	55                   	push   %ebp
c01012da:	89 e5                	mov    %esp,%ebp
c01012dc:	56                   	push   %esi
c01012dd:	53                   	push   %ebx
c01012de:	83 ec 40             	sub    $0x40,%esp
c01012e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01012e4:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01012e8:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c01012ef:	77 25                	ja     c0101316 <ide_write_secs+0x3d>
c01012f1:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c01012f6:	77 1e                	ja     c0101316 <ide_write_secs+0x3d>
c01012f8:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01012fc:	c1 e0 03             	shl    $0x3,%eax
c01012ff:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101306:	29 c2                	sub    %eax,%edx
c0101308:	89 d0                	mov    %edx,%eax
c010130a:	05 40 74 12 c0       	add    $0xc0127440,%eax
c010130f:	0f b6 00             	movzbl (%eax),%eax
c0101312:	84 c0                	test   %al,%al
c0101314:	75 19                	jne    c010132f <ide_write_secs+0x56>
c0101316:	68 1c 98 10 c0       	push   $0xc010981c
c010131b:	68 d7 97 10 c0       	push   $0xc01097d7
c0101320:	68 bc 00 00 00       	push   $0xbc
c0101325:	68 ec 97 10 c0       	push   $0xc01097ec
c010132a:	e8 c1 f0 ff ff       	call   c01003f0 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c010132f:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101336:	77 0f                	ja     c0101347 <ide_write_secs+0x6e>
c0101338:	8b 55 0c             	mov    0xc(%ebp),%edx
c010133b:	8b 45 14             	mov    0x14(%ebp),%eax
c010133e:	01 d0                	add    %edx,%eax
c0101340:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101345:	76 19                	jbe    c0101360 <ide_write_secs+0x87>
c0101347:	68 44 98 10 c0       	push   $0xc0109844
c010134c:	68 d7 97 10 c0       	push   $0xc01097d7
c0101351:	68 bd 00 00 00       	push   $0xbd
c0101356:	68 ec 97 10 c0       	push   $0xc01097ec
c010135b:	e8 90 f0 ff ff       	call   c01003f0 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101360:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101364:	66 d1 e8             	shr    %ax
c0101367:	0f b7 c0             	movzwl %ax,%eax
c010136a:	0f b7 04 85 8c 97 10 	movzwl -0x3fef6874(,%eax,4),%eax
c0101371:	c0 
c0101372:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101376:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010137a:	66 d1 e8             	shr    %ax
c010137d:	0f b7 c0             	movzwl %ax,%eax
c0101380:	0f b7 04 85 8e 97 10 	movzwl -0x3fef6872(,%eax,4),%eax
c0101387:	c0 
c0101388:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c010138c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101390:	83 ec 08             	sub    $0x8,%esp
c0101393:	6a 00                	push   $0x0
c0101395:	50                   	push   %eax
c0101396:	e8 36 f9 ff ff       	call   c0100cd1 <ide_wait_ready>
c010139b:	83 c4 10             	add    $0x10,%esp

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c010139e:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01013a2:	83 c0 02             	add    $0x2,%eax
c01013a5:	0f b7 c0             	movzwl %ax,%eax
c01013a8:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01013ac:	c6 45 d7 00          	movb   $0x0,-0x29(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01013b0:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c01013b4:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01013b8:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c01013b9:	8b 45 14             	mov    0x14(%ebp),%eax
c01013bc:	0f b6 c0             	movzbl %al,%eax
c01013bf:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01013c3:	83 c2 02             	add    $0x2,%edx
c01013c6:	0f b7 d2             	movzwl %dx,%edx
c01013c9:	66 89 55 e8          	mov    %dx,-0x18(%ebp)
c01013cd:	88 45 d8             	mov    %al,-0x28(%ebp)
c01013d0:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c01013d4:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01013d8:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c01013d9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01013dc:	0f b6 c0             	movzbl %al,%eax
c01013df:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01013e3:	83 c2 03             	add    $0x3,%edx
c01013e6:	0f b7 d2             	movzwl %dx,%edx
c01013e9:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01013ed:	88 45 d9             	mov    %al,-0x27(%ebp)
c01013f0:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01013f4:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01013f8:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c01013f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01013fc:	c1 e8 08             	shr    $0x8,%eax
c01013ff:	0f b6 c0             	movzbl %al,%eax
c0101402:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101406:	83 c2 04             	add    $0x4,%edx
c0101409:	0f b7 d2             	movzwl %dx,%edx
c010140c:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
c0101410:	88 45 da             	mov    %al,-0x26(%ebp)
c0101413:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c0101417:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
c010141b:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c010141c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010141f:	c1 e8 10             	shr    $0x10,%eax
c0101422:	0f b6 c0             	movzbl %al,%eax
c0101425:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101429:	83 c2 05             	add    $0x5,%edx
c010142c:	0f b7 d2             	movzwl %dx,%edx
c010142f:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101433:	88 45 db             	mov    %al,-0x25(%ebp)
c0101436:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c010143a:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010143e:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c010143f:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101443:	83 e0 01             	and    $0x1,%eax
c0101446:	c1 e0 04             	shl    $0x4,%eax
c0101449:	89 c2                	mov    %eax,%edx
c010144b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010144e:	c1 e8 18             	shr    $0x18,%eax
c0101451:	83 e0 0f             	and    $0xf,%eax
c0101454:	09 d0                	or     %edx,%eax
c0101456:	83 c8 e0             	or     $0xffffffe0,%eax
c0101459:	0f b6 c0             	movzbl %al,%eax
c010145c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101460:	83 c2 06             	add    $0x6,%edx
c0101463:	0f b7 d2             	movzwl %dx,%edx
c0101466:	66 89 55 e0          	mov    %dx,-0x20(%ebp)
c010146a:	88 45 dc             	mov    %al,-0x24(%ebp)
c010146d:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0101471:	0f b7 55 e0          	movzwl -0x20(%ebp),%edx
c0101475:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0101476:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010147a:	83 c0 07             	add    $0x7,%eax
c010147d:	0f b7 c0             	movzwl %ax,%eax
c0101480:	66 89 45 de          	mov    %ax,-0x22(%ebp)
c0101484:	c6 45 dd 30          	movb   $0x30,-0x23(%ebp)
c0101488:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010148c:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101490:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101491:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101498:	eb 56                	jmp    c01014f0 <ide_write_secs+0x217>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c010149a:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010149e:	83 ec 08             	sub    $0x8,%esp
c01014a1:	6a 01                	push   $0x1
c01014a3:	50                   	push   %eax
c01014a4:	e8 28 f8 ff ff       	call   c0100cd1 <ide_wait_ready>
c01014a9:	83 c4 10             	add    $0x10,%esp
c01014ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01014af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01014b3:	75 43                	jne    c01014f8 <ide_write_secs+0x21f>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c01014b5:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01014b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01014bc:	8b 45 10             	mov    0x10(%ebp),%eax
c01014bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01014c2:	c7 45 cc 80 00 00 00 	movl   $0x80,-0x34(%ebp)
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port) : "memory");
}

static inline void
outsl(uint32_t port, const void *addr, int cnt) {
    asm volatile (
c01014c9:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01014cc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c01014cf:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01014d2:	89 cb                	mov    %ecx,%ebx
c01014d4:	89 de                	mov    %ebx,%esi
c01014d6:	89 c1                	mov    %eax,%ecx
c01014d8:	fc                   	cld    
c01014d9:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c01014db:	89 c8                	mov    %ecx,%eax
c01014dd:	89 f3                	mov    %esi,%ebx
c01014df:	89 5d d0             	mov    %ebx,-0x30(%ebp)
c01014e2:	89 45 cc             	mov    %eax,-0x34(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);

    int ret = 0;
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c01014e5:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c01014e9:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01014f0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01014f4:	75 a4                	jne    c010149a <ide_write_secs+0x1c1>
c01014f6:	eb 01                	jmp    c01014f9 <ide_write_secs+0x220>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
            goto out;
c01014f8:	90                   	nop
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c01014f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01014fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
c01014ff:	5b                   	pop    %ebx
c0101500:	5e                   	pop    %esi
c0101501:	5d                   	pop    %ebp
c0101502:	c3                   	ret    

c0101503 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0101503:	55                   	push   %ebp
c0101504:	89 e5                	mov    %esp,%ebp
c0101506:	83 ec 18             	sub    $0x18,%esp
c0101509:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c010150f:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101513:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
c0101517:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010151b:	ee                   	out    %al,(%dx)
c010151c:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
c0101522:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
c0101526:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c010152a:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
c010152e:	ee                   	out    %al,(%dx)
c010152f:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0101535:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
c0101539:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010153d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101541:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0101542:	c7 05 54 a0 12 c0 00 	movl   $0x0,0xc012a054
c0101549:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c010154c:	83 ec 0c             	sub    $0xc,%esp
c010154f:	68 7e 98 10 c0       	push   $0xc010987e
c0101554:	e8 31 ed ff ff       	call   c010028a <cprintf>
c0101559:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_TIMER);
c010155c:	83 ec 0c             	sub    $0xc,%esp
c010155f:	6a 00                	push   $0x0
c0101561:	e8 3b 09 00 00       	call   c0101ea1 <pic_enable>
c0101566:	83 c4 10             	add    $0x10,%esp
}
c0101569:	90                   	nop
c010156a:	c9                   	leave  
c010156b:	c3                   	ret    

c010156c <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c010156c:	55                   	push   %ebp
c010156d:	89 e5                	mov    %esp,%ebp
c010156f:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0101572:	9c                   	pushf  
c0101573:	58                   	pop    %eax
c0101574:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0101577:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010157a:	25 00 02 00 00       	and    $0x200,%eax
c010157f:	85 c0                	test   %eax,%eax
c0101581:	74 0c                	je     c010158f <__intr_save+0x23>
        intr_disable();
c0101583:	e8 8a 0a 00 00       	call   c0102012 <intr_disable>
        return 1;
c0101588:	b8 01 00 00 00       	mov    $0x1,%eax
c010158d:	eb 05                	jmp    c0101594 <__intr_save+0x28>
    }
    return 0;
c010158f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101594:	c9                   	leave  
c0101595:	c3                   	ret    

c0101596 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0101596:	55                   	push   %ebp
c0101597:	89 e5                	mov    %esp,%ebp
c0101599:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010159c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01015a0:	74 05                	je     c01015a7 <__intr_restore+0x11>
        intr_enable();
c01015a2:	e8 64 0a 00 00       	call   c010200b <intr_enable>
    }
}
c01015a7:	90                   	nop
c01015a8:	c9                   	leave  
c01015a9:	c3                   	ret    

c01015aa <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c01015aa:	55                   	push   %ebp
c01015ab:	89 e5                	mov    %esp,%ebp
c01015ad:	83 ec 10             	sub    $0x10,%esp
c01015b0:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01015b6:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01015ba:	89 c2                	mov    %eax,%edx
c01015bc:	ec                   	in     (%dx),%al
c01015bd:	88 45 f4             	mov    %al,-0xc(%ebp)
c01015c0:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
c01015c6:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c01015ca:	89 c2                	mov    %eax,%edx
c01015cc:	ec                   	in     (%dx),%al
c01015cd:	88 45 f5             	mov    %al,-0xb(%ebp)
c01015d0:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c01015d6:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01015da:	89 c2                	mov    %eax,%edx
c01015dc:	ec                   	in     (%dx),%al
c01015dd:	88 45 f6             	mov    %al,-0xa(%ebp)
c01015e0:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
c01015e6:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
c01015ea:	89 c2                	mov    %eax,%edx
c01015ec:	ec                   	in     (%dx),%al
c01015ed:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c01015f0:	90                   	nop
c01015f1:	c9                   	leave  
c01015f2:	c3                   	ret    

c01015f3 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c01015f3:	55                   	push   %ebp
c01015f4:	89 e5                	mov    %esp,%ebp
c01015f6:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c01015f9:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0101600:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101603:	0f b7 00             	movzwl (%eax),%eax
c0101606:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c010160a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010160d:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0101612:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101615:	0f b7 00             	movzwl (%eax),%eax
c0101618:	66 3d 5a a5          	cmp    $0xa55a,%ax
c010161c:	74 12                	je     c0101630 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c010161e:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0101625:	66 c7 05 26 75 12 c0 	movw   $0x3b4,0xc0127526
c010162c:	b4 03 
c010162e:	eb 13                	jmp    c0101643 <cga_init+0x50>
    } else {
        *cp = was;
c0101630:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101633:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101637:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c010163a:	66 c7 05 26 75 12 c0 	movw   $0x3d4,0xc0127526
c0101641:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0101643:	0f b7 05 26 75 12 c0 	movzwl 0xc0127526,%eax
c010164a:	0f b7 c0             	movzwl %ax,%eax
c010164d:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
c0101651:	c6 45 ea 0e          	movb   $0xe,-0x16(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101655:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c0101659:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
c010165d:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c010165e:	0f b7 05 26 75 12 c0 	movzwl 0xc0127526,%eax
c0101665:	83 c0 01             	add    $0x1,%eax
c0101668:	0f b7 c0             	movzwl %ax,%eax
c010166b:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010166f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101673:	89 c2                	mov    %eax,%edx
c0101675:	ec                   	in     (%dx),%al
c0101676:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101679:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c010167d:	0f b6 c0             	movzbl %al,%eax
c0101680:	c1 e0 08             	shl    $0x8,%eax
c0101683:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0101686:	0f b7 05 26 75 12 c0 	movzwl 0xc0127526,%eax
c010168d:	0f b7 c0             	movzwl %ax,%eax
c0101690:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
c0101694:	c6 45 ec 0f          	movb   $0xf,-0x14(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101698:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
c010169c:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c01016a0:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c01016a1:	0f b7 05 26 75 12 c0 	movzwl 0xc0127526,%eax
c01016a8:	83 c0 01             	add    $0x1,%eax
c01016ab:	0f b7 c0             	movzwl %ax,%eax
c01016ae:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01016b2:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c01016b6:	89 c2                	mov    %eax,%edx
c01016b8:	ec                   	in     (%dx),%al
c01016b9:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c01016bc:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01016c0:	0f b6 c0             	movzbl %al,%eax
c01016c3:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c01016c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01016c9:	a3 20 75 12 c0       	mov    %eax,0xc0127520
    crt_pos = pos;
c01016ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01016d1:	66 a3 24 75 12 c0    	mov    %ax,0xc0127524
}
c01016d7:	90                   	nop
c01016d8:	c9                   	leave  
c01016d9:	c3                   	ret    

c01016da <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c01016da:	55                   	push   %ebp
c01016db:	89 e5                	mov    %esp,%ebp
c01016dd:	83 ec 28             	sub    $0x28,%esp
c01016e0:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c01016e6:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01016ea:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c01016ee:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01016f2:	ee                   	out    %al,(%dx)
c01016f3:	66 c7 45 f4 fb 03    	movw   $0x3fb,-0xc(%ebp)
c01016f9:	c6 45 db 80          	movb   $0x80,-0x25(%ebp)
c01016fd:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0101701:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
c0101705:	ee                   	out    %al,(%dx)
c0101706:	66 c7 45 f2 f8 03    	movw   $0x3f8,-0xe(%ebp)
c010170c:	c6 45 dc 0c          	movb   $0xc,-0x24(%ebp)
c0101710:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0101714:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101718:	ee                   	out    %al,(%dx)
c0101719:	66 c7 45 f0 f9 03    	movw   $0x3f9,-0x10(%ebp)
c010171f:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
c0101723:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101727:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c010172b:	ee                   	out    %al,(%dx)
c010172c:	66 c7 45 ee fb 03    	movw   $0x3fb,-0x12(%ebp)
c0101732:	c6 45 de 03          	movb   $0x3,-0x22(%ebp)
c0101736:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c010173a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010173e:	ee                   	out    %al,(%dx)
c010173f:	66 c7 45 ec fc 03    	movw   $0x3fc,-0x14(%ebp)
c0101745:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
c0101749:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c010174d:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
c0101751:	ee                   	out    %al,(%dx)
c0101752:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0101758:	c6 45 e0 01          	movb   $0x1,-0x20(%ebp)
c010175c:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c0101760:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101764:	ee                   	out    %al,(%dx)
c0101765:	66 c7 45 e8 fd 03    	movw   $0x3fd,-0x18(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010176b:	0f b7 45 e8          	movzwl -0x18(%ebp),%eax
c010176f:	89 c2                	mov    %eax,%edx
c0101771:	ec                   	in     (%dx),%al
c0101772:	88 45 e1             	mov    %al,-0x1f(%ebp)
    return data;
c0101775:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101779:	3c ff                	cmp    $0xff,%al
c010177b:	0f 95 c0             	setne  %al
c010177e:	0f b6 c0             	movzbl %al,%eax
c0101781:	a3 28 75 12 c0       	mov    %eax,0xc0127528
c0101786:	66 c7 45 e6 fa 03    	movw   $0x3fa,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010178c:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0101790:	89 c2                	mov    %eax,%edx
c0101792:	ec                   	in     (%dx),%al
c0101793:	88 45 e2             	mov    %al,-0x1e(%ebp)
c0101796:	66 c7 45 e4 f8 03    	movw   $0x3f8,-0x1c(%ebp)
c010179c:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
c01017a0:	89 c2                	mov    %eax,%edx
c01017a2:	ec                   	in     (%dx),%al
c01017a3:	88 45 e3             	mov    %al,-0x1d(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c01017a6:	a1 28 75 12 c0       	mov    0xc0127528,%eax
c01017ab:	85 c0                	test   %eax,%eax
c01017ad:	74 0d                	je     c01017bc <serial_init+0xe2>
        pic_enable(IRQ_COM1);
c01017af:	83 ec 0c             	sub    $0xc,%esp
c01017b2:	6a 04                	push   $0x4
c01017b4:	e8 e8 06 00 00       	call   c0101ea1 <pic_enable>
c01017b9:	83 c4 10             	add    $0x10,%esp
    }
}
c01017bc:	90                   	nop
c01017bd:	c9                   	leave  
c01017be:	c3                   	ret    

c01017bf <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c01017bf:	55                   	push   %ebp
c01017c0:	89 e5                	mov    %esp,%ebp
c01017c2:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01017c5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01017cc:	eb 09                	jmp    c01017d7 <lpt_putc_sub+0x18>
        delay();
c01017ce:	e8 d7 fd ff ff       	call   c01015aa <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01017d3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01017d7:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
c01017dd:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01017e1:	89 c2                	mov    %eax,%edx
c01017e3:	ec                   	in     (%dx),%al
c01017e4:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
c01017e7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01017eb:	84 c0                	test   %al,%al
c01017ed:	78 09                	js     c01017f8 <lpt_putc_sub+0x39>
c01017ef:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01017f6:	7e d6                	jle    c01017ce <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c01017f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01017fb:	0f b6 c0             	movzbl %al,%eax
c01017fe:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
c0101804:	88 45 f0             	mov    %al,-0x10(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101807:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c010180b:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
c010180f:	ee                   	out    %al,(%dx)
c0101810:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c0101816:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c010181a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010181e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101822:	ee                   	out    %al,(%dx)
c0101823:	66 c7 45 fa 7a 03    	movw   $0x37a,-0x6(%ebp)
c0101829:	c6 45 f2 08          	movb   $0x8,-0xe(%ebp)
c010182d:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
c0101831:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101835:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0101836:	90                   	nop
c0101837:	c9                   	leave  
c0101838:	c3                   	ret    

c0101839 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101839:	55                   	push   %ebp
c010183a:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
c010183c:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101840:	74 0d                	je     c010184f <lpt_putc+0x16>
        lpt_putc_sub(c);
c0101842:	ff 75 08             	pushl  0x8(%ebp)
c0101845:	e8 75 ff ff ff       	call   c01017bf <lpt_putc_sub>
c010184a:	83 c4 04             	add    $0x4,%esp
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c010184d:	eb 1e                	jmp    c010186d <lpt_putc+0x34>
lpt_putc(int c) {
    if (c != '\b') {
        lpt_putc_sub(c);
    }
    else {
        lpt_putc_sub('\b');
c010184f:	6a 08                	push   $0x8
c0101851:	e8 69 ff ff ff       	call   c01017bf <lpt_putc_sub>
c0101856:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub(' ');
c0101859:	6a 20                	push   $0x20
c010185b:	e8 5f ff ff ff       	call   c01017bf <lpt_putc_sub>
c0101860:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub('\b');
c0101863:	6a 08                	push   $0x8
c0101865:	e8 55 ff ff ff       	call   c01017bf <lpt_putc_sub>
c010186a:	83 c4 04             	add    $0x4,%esp
    }
}
c010186d:	90                   	nop
c010186e:	c9                   	leave  
c010186f:	c3                   	ret    

c0101870 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101870:	55                   	push   %ebp
c0101871:	89 e5                	mov    %esp,%ebp
c0101873:	53                   	push   %ebx
c0101874:	83 ec 14             	sub    $0x14,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101877:	8b 45 08             	mov    0x8(%ebp),%eax
c010187a:	b0 00                	mov    $0x0,%al
c010187c:	85 c0                	test   %eax,%eax
c010187e:	75 07                	jne    c0101887 <cga_putc+0x17>
        c |= 0x0700;
c0101880:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101887:	8b 45 08             	mov    0x8(%ebp),%eax
c010188a:	0f b6 c0             	movzbl %al,%eax
c010188d:	83 f8 0a             	cmp    $0xa,%eax
c0101890:	74 4e                	je     c01018e0 <cga_putc+0x70>
c0101892:	83 f8 0d             	cmp    $0xd,%eax
c0101895:	74 59                	je     c01018f0 <cga_putc+0x80>
c0101897:	83 f8 08             	cmp    $0x8,%eax
c010189a:	0f 85 8a 00 00 00    	jne    c010192a <cga_putc+0xba>
    case '\b':
        if (crt_pos > 0) {
c01018a0:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c01018a7:	66 85 c0             	test   %ax,%ax
c01018aa:	0f 84 a0 00 00 00    	je     c0101950 <cga_putc+0xe0>
            crt_pos --;
c01018b0:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c01018b7:	83 e8 01             	sub    $0x1,%eax
c01018ba:	66 a3 24 75 12 c0    	mov    %ax,0xc0127524
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01018c0:	a1 20 75 12 c0       	mov    0xc0127520,%eax
c01018c5:	0f b7 15 24 75 12 c0 	movzwl 0xc0127524,%edx
c01018cc:	0f b7 d2             	movzwl %dx,%edx
c01018cf:	01 d2                	add    %edx,%edx
c01018d1:	01 d0                	add    %edx,%eax
c01018d3:	8b 55 08             	mov    0x8(%ebp),%edx
c01018d6:	b2 00                	mov    $0x0,%dl
c01018d8:	83 ca 20             	or     $0x20,%edx
c01018db:	66 89 10             	mov    %dx,(%eax)
        }
        break;
c01018de:	eb 70                	jmp    c0101950 <cga_putc+0xe0>
    case '\n':
        crt_pos += CRT_COLS;
c01018e0:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c01018e7:	83 c0 50             	add    $0x50,%eax
c01018ea:	66 a3 24 75 12 c0    	mov    %ax,0xc0127524
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01018f0:	0f b7 1d 24 75 12 c0 	movzwl 0xc0127524,%ebx
c01018f7:	0f b7 0d 24 75 12 c0 	movzwl 0xc0127524,%ecx
c01018fe:	0f b7 c1             	movzwl %cx,%eax
c0101901:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c0101907:	c1 e8 10             	shr    $0x10,%eax
c010190a:	89 c2                	mov    %eax,%edx
c010190c:	66 c1 ea 06          	shr    $0x6,%dx
c0101910:	89 d0                	mov    %edx,%eax
c0101912:	c1 e0 02             	shl    $0x2,%eax
c0101915:	01 d0                	add    %edx,%eax
c0101917:	c1 e0 04             	shl    $0x4,%eax
c010191a:	29 c1                	sub    %eax,%ecx
c010191c:	89 ca                	mov    %ecx,%edx
c010191e:	89 d8                	mov    %ebx,%eax
c0101920:	29 d0                	sub    %edx,%eax
c0101922:	66 a3 24 75 12 c0    	mov    %ax,0xc0127524
        break;
c0101928:	eb 27                	jmp    c0101951 <cga_putc+0xe1>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c010192a:	8b 0d 20 75 12 c0    	mov    0xc0127520,%ecx
c0101930:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c0101937:	8d 50 01             	lea    0x1(%eax),%edx
c010193a:	66 89 15 24 75 12 c0 	mov    %dx,0xc0127524
c0101941:	0f b7 c0             	movzwl %ax,%eax
c0101944:	01 c0                	add    %eax,%eax
c0101946:	01 c8                	add    %ecx,%eax
c0101948:	8b 55 08             	mov    0x8(%ebp),%edx
c010194b:	66 89 10             	mov    %dx,(%eax)
        break;
c010194e:	eb 01                	jmp    c0101951 <cga_putc+0xe1>
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
c0101950:	90                   	nop
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101951:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c0101958:	66 3d cf 07          	cmp    $0x7cf,%ax
c010195c:	76 59                	jbe    c01019b7 <cga_putc+0x147>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c010195e:	a1 20 75 12 c0       	mov    0xc0127520,%eax
c0101963:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101969:	a1 20 75 12 c0       	mov    0xc0127520,%eax
c010196e:	83 ec 04             	sub    $0x4,%esp
c0101971:	68 00 0f 00 00       	push   $0xf00
c0101976:	52                   	push   %edx
c0101977:	50                   	push   %eax
c0101978:	e8 c9 72 00 00       	call   c0108c46 <memmove>
c010197d:	83 c4 10             	add    $0x10,%esp
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101980:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101987:	eb 15                	jmp    c010199e <cga_putc+0x12e>
            crt_buf[i] = 0x0700 | ' ';
c0101989:	a1 20 75 12 c0       	mov    0xc0127520,%eax
c010198e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101991:	01 d2                	add    %edx,%edx
c0101993:	01 d0                	add    %edx,%eax
c0101995:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010199a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010199e:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c01019a5:	7e e2                	jle    c0101989 <cga_putc+0x119>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c01019a7:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c01019ae:	83 e8 50             	sub    $0x50,%eax
c01019b1:	66 a3 24 75 12 c0    	mov    %ax,0xc0127524
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c01019b7:	0f b7 05 26 75 12 c0 	movzwl 0xc0127526,%eax
c01019be:	0f b7 c0             	movzwl %ax,%eax
c01019c1:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c01019c5:	c6 45 e8 0e          	movb   $0xe,-0x18(%ebp)
c01019c9:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
c01019cd:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01019d1:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c01019d2:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c01019d9:	66 c1 e8 08          	shr    $0x8,%ax
c01019dd:	0f b6 c0             	movzbl %al,%eax
c01019e0:	0f b7 15 26 75 12 c0 	movzwl 0xc0127526,%edx
c01019e7:	83 c2 01             	add    $0x1,%edx
c01019ea:	0f b7 d2             	movzwl %dx,%edx
c01019ed:	66 89 55 f0          	mov    %dx,-0x10(%ebp)
c01019f1:	88 45 e9             	mov    %al,-0x17(%ebp)
c01019f4:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01019f8:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c01019fc:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c01019fd:	0f b7 05 26 75 12 c0 	movzwl 0xc0127526,%eax
c0101a04:	0f b7 c0             	movzwl %ax,%eax
c0101a07:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101a0b:	c6 45 ea 0f          	movb   $0xf,-0x16(%ebp)
c0101a0f:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c0101a13:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101a17:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c0101a18:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c0101a1f:	0f b6 c0             	movzbl %al,%eax
c0101a22:	0f b7 15 26 75 12 c0 	movzwl 0xc0127526,%edx
c0101a29:	83 c2 01             	add    $0x1,%edx
c0101a2c:	0f b7 d2             	movzwl %dx,%edx
c0101a2f:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
c0101a33:	88 45 eb             	mov    %al,-0x15(%ebp)
c0101a36:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c0101a3a:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
c0101a3e:	ee                   	out    %al,(%dx)
}
c0101a3f:	90                   	nop
c0101a40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101a43:	c9                   	leave  
c0101a44:	c3                   	ret    

c0101a45 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101a45:	55                   	push   %ebp
c0101a46:	89 e5                	mov    %esp,%ebp
c0101a48:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101a4b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101a52:	eb 09                	jmp    c0101a5d <serial_putc_sub+0x18>
        delay();
c0101a54:	e8 51 fb ff ff       	call   c01015aa <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101a59:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101a5d:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101a63:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
c0101a67:	89 c2                	mov    %eax,%edx
c0101a69:	ec                   	in     (%dx),%al
c0101a6a:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c0101a6d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0101a71:	0f b6 c0             	movzbl %al,%eax
c0101a74:	83 e0 20             	and    $0x20,%eax
c0101a77:	85 c0                	test   %eax,%eax
c0101a79:	75 09                	jne    c0101a84 <serial_putc_sub+0x3f>
c0101a7b:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101a82:	7e d0                	jle    c0101a54 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c0101a84:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a87:	0f b6 c0             	movzbl %al,%eax
c0101a8a:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
c0101a90:	88 45 f6             	mov    %al,-0xa(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101a93:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
c0101a97:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101a9b:	ee                   	out    %al,(%dx)
}
c0101a9c:	90                   	nop
c0101a9d:	c9                   	leave  
c0101a9e:	c3                   	ret    

c0101a9f <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101a9f:	55                   	push   %ebp
c0101aa0:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
c0101aa2:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101aa6:	74 0d                	je     c0101ab5 <serial_putc+0x16>
        serial_putc_sub(c);
c0101aa8:	ff 75 08             	pushl  0x8(%ebp)
c0101aab:	e8 95 ff ff ff       	call   c0101a45 <serial_putc_sub>
c0101ab0:	83 c4 04             	add    $0x4,%esp
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c0101ab3:	eb 1e                	jmp    c0101ad3 <serial_putc+0x34>
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
c0101ab5:	6a 08                	push   $0x8
c0101ab7:	e8 89 ff ff ff       	call   c0101a45 <serial_putc_sub>
c0101abc:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub(' ');
c0101abf:	6a 20                	push   $0x20
c0101ac1:	e8 7f ff ff ff       	call   c0101a45 <serial_putc_sub>
c0101ac6:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub('\b');
c0101ac9:	6a 08                	push   $0x8
c0101acb:	e8 75 ff ff ff       	call   c0101a45 <serial_putc_sub>
c0101ad0:	83 c4 04             	add    $0x4,%esp
    }
}
c0101ad3:	90                   	nop
c0101ad4:	c9                   	leave  
c0101ad5:	c3                   	ret    

c0101ad6 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101ad6:	55                   	push   %ebp
c0101ad7:	89 e5                	mov    %esp,%ebp
c0101ad9:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101adc:	eb 33                	jmp    c0101b11 <cons_intr+0x3b>
        if (c != 0) {
c0101ade:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101ae2:	74 2d                	je     c0101b11 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101ae4:	a1 44 77 12 c0       	mov    0xc0127744,%eax
c0101ae9:	8d 50 01             	lea    0x1(%eax),%edx
c0101aec:	89 15 44 77 12 c0    	mov    %edx,0xc0127744
c0101af2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101af5:	88 90 40 75 12 c0    	mov    %dl,-0x3fed8ac0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101afb:	a1 44 77 12 c0       	mov    0xc0127744,%eax
c0101b00:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101b05:	75 0a                	jne    c0101b11 <cons_intr+0x3b>
                cons.wpos = 0;
c0101b07:	c7 05 44 77 12 c0 00 	movl   $0x0,0xc0127744
c0101b0e:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c0101b11:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b14:	ff d0                	call   *%eax
c0101b16:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101b19:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101b1d:	75 bf                	jne    c0101ade <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c0101b1f:	90                   	nop
c0101b20:	c9                   	leave  
c0101b21:	c3                   	ret    

c0101b22 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101b22:	55                   	push   %ebp
c0101b23:	89 e5                	mov    %esp,%ebp
c0101b25:	83 ec 10             	sub    $0x10,%esp
c0101b28:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101b2e:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
c0101b32:	89 c2                	mov    %eax,%edx
c0101b34:	ec                   	in     (%dx),%al
c0101b35:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c0101b38:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101b3c:	0f b6 c0             	movzbl %al,%eax
c0101b3f:	83 e0 01             	and    $0x1,%eax
c0101b42:	85 c0                	test   %eax,%eax
c0101b44:	75 07                	jne    c0101b4d <serial_proc_data+0x2b>
        return -1;
c0101b46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101b4b:	eb 2a                	jmp    c0101b77 <serial_proc_data+0x55>
c0101b4d:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101b53:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101b57:	89 c2                	mov    %eax,%edx
c0101b59:	ec                   	in     (%dx),%al
c0101b5a:	88 45 f6             	mov    %al,-0xa(%ebp)
    return data;
c0101b5d:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101b61:	0f b6 c0             	movzbl %al,%eax
c0101b64:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101b67:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101b6b:	75 07                	jne    c0101b74 <serial_proc_data+0x52>
        c = '\b';
c0101b6d:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101b74:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101b77:	c9                   	leave  
c0101b78:	c3                   	ret    

c0101b79 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101b79:	55                   	push   %ebp
c0101b7a:	89 e5                	mov    %esp,%ebp
c0101b7c:	83 ec 08             	sub    $0x8,%esp
    if (serial_exists) {
c0101b7f:	a1 28 75 12 c0       	mov    0xc0127528,%eax
c0101b84:	85 c0                	test   %eax,%eax
c0101b86:	74 10                	je     c0101b98 <serial_intr+0x1f>
        cons_intr(serial_proc_data);
c0101b88:	83 ec 0c             	sub    $0xc,%esp
c0101b8b:	68 22 1b 10 c0       	push   $0xc0101b22
c0101b90:	e8 41 ff ff ff       	call   c0101ad6 <cons_intr>
c0101b95:	83 c4 10             	add    $0x10,%esp
    }
}
c0101b98:	90                   	nop
c0101b99:	c9                   	leave  
c0101b9a:	c3                   	ret    

c0101b9b <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101b9b:	55                   	push   %ebp
c0101b9c:	89 e5                	mov    %esp,%ebp
c0101b9e:	83 ec 18             	sub    $0x18,%esp
c0101ba1:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101ba7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101bab:	89 c2                	mov    %eax,%edx
c0101bad:	ec                   	in     (%dx),%al
c0101bae:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101bb1:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101bb5:	0f b6 c0             	movzbl %al,%eax
c0101bb8:	83 e0 01             	and    $0x1,%eax
c0101bbb:	85 c0                	test   %eax,%eax
c0101bbd:	75 0a                	jne    c0101bc9 <kbd_proc_data+0x2e>
        return -1;
c0101bbf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101bc4:	e9 5d 01 00 00       	jmp    c0101d26 <kbd_proc_data+0x18b>
c0101bc9:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101bcf:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101bd3:	89 c2                	mov    %eax,%edx
c0101bd5:	ec                   	in     (%dx),%al
c0101bd6:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
c0101bd9:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101bdd:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101be0:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101be4:	75 17                	jne    c0101bfd <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c0101be6:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101beb:	83 c8 40             	or     $0x40,%eax
c0101bee:	a3 48 77 12 c0       	mov    %eax,0xc0127748
        return 0;
c0101bf3:	b8 00 00 00 00       	mov    $0x0,%eax
c0101bf8:	e9 29 01 00 00       	jmp    c0101d26 <kbd_proc_data+0x18b>
    } else if (data & 0x80) {
c0101bfd:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101c01:	84 c0                	test   %al,%al
c0101c03:	79 47                	jns    c0101c4c <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101c05:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101c0a:	83 e0 40             	and    $0x40,%eax
c0101c0d:	85 c0                	test   %eax,%eax
c0101c0f:	75 09                	jne    c0101c1a <kbd_proc_data+0x7f>
c0101c11:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101c15:	83 e0 7f             	and    $0x7f,%eax
c0101c18:	eb 04                	jmp    c0101c1e <kbd_proc_data+0x83>
c0101c1a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101c1e:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101c21:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101c25:	0f b6 80 40 40 12 c0 	movzbl -0x3fedbfc0(%eax),%eax
c0101c2c:	83 c8 40             	or     $0x40,%eax
c0101c2f:	0f b6 c0             	movzbl %al,%eax
c0101c32:	f7 d0                	not    %eax
c0101c34:	89 c2                	mov    %eax,%edx
c0101c36:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101c3b:	21 d0                	and    %edx,%eax
c0101c3d:	a3 48 77 12 c0       	mov    %eax,0xc0127748
        return 0;
c0101c42:	b8 00 00 00 00       	mov    $0x0,%eax
c0101c47:	e9 da 00 00 00       	jmp    c0101d26 <kbd_proc_data+0x18b>
    } else if (shift & E0ESC) {
c0101c4c:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101c51:	83 e0 40             	and    $0x40,%eax
c0101c54:	85 c0                	test   %eax,%eax
c0101c56:	74 11                	je     c0101c69 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101c58:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101c5c:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101c61:	83 e0 bf             	and    $0xffffffbf,%eax
c0101c64:	a3 48 77 12 c0       	mov    %eax,0xc0127748
    }

    shift |= shiftcode[data];
c0101c69:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101c6d:	0f b6 80 40 40 12 c0 	movzbl -0x3fedbfc0(%eax),%eax
c0101c74:	0f b6 d0             	movzbl %al,%edx
c0101c77:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101c7c:	09 d0                	or     %edx,%eax
c0101c7e:	a3 48 77 12 c0       	mov    %eax,0xc0127748
    shift ^= togglecode[data];
c0101c83:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101c87:	0f b6 80 40 41 12 c0 	movzbl -0x3fedbec0(%eax),%eax
c0101c8e:	0f b6 d0             	movzbl %al,%edx
c0101c91:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101c96:	31 d0                	xor    %edx,%eax
c0101c98:	a3 48 77 12 c0       	mov    %eax,0xc0127748

    c = charcode[shift & (CTL | SHIFT)][data];
c0101c9d:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101ca2:	83 e0 03             	and    $0x3,%eax
c0101ca5:	8b 14 85 40 45 12 c0 	mov    -0x3fedbac0(,%eax,4),%edx
c0101cac:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101cb0:	01 d0                	add    %edx,%eax
c0101cb2:	0f b6 00             	movzbl (%eax),%eax
c0101cb5:	0f b6 c0             	movzbl %al,%eax
c0101cb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101cbb:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101cc0:	83 e0 08             	and    $0x8,%eax
c0101cc3:	85 c0                	test   %eax,%eax
c0101cc5:	74 22                	je     c0101ce9 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c0101cc7:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101ccb:	7e 0c                	jle    c0101cd9 <kbd_proc_data+0x13e>
c0101ccd:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101cd1:	7f 06                	jg     c0101cd9 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101cd3:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101cd7:	eb 10                	jmp    c0101ce9 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101cd9:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101cdd:	7e 0a                	jle    c0101ce9 <kbd_proc_data+0x14e>
c0101cdf:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101ce3:	7f 04                	jg     c0101ce9 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c0101ce5:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101ce9:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101cee:	f7 d0                	not    %eax
c0101cf0:	83 e0 06             	and    $0x6,%eax
c0101cf3:	85 c0                	test   %eax,%eax
c0101cf5:	75 2c                	jne    c0101d23 <kbd_proc_data+0x188>
c0101cf7:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101cfe:	75 23                	jne    c0101d23 <kbd_proc_data+0x188>
        cprintf("Rebooting!\n");
c0101d00:	83 ec 0c             	sub    $0xc,%esp
c0101d03:	68 99 98 10 c0       	push   $0xc0109899
c0101d08:	e8 7d e5 ff ff       	call   c010028a <cprintf>
c0101d0d:	83 c4 10             	add    $0x10,%esp
c0101d10:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
c0101d16:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101d1a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101d1e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101d22:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101d26:	c9                   	leave  
c0101d27:	c3                   	ret    

c0101d28 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101d28:	55                   	push   %ebp
c0101d29:	89 e5                	mov    %esp,%ebp
c0101d2b:	83 ec 08             	sub    $0x8,%esp
    cons_intr(kbd_proc_data);
c0101d2e:	83 ec 0c             	sub    $0xc,%esp
c0101d31:	68 9b 1b 10 c0       	push   $0xc0101b9b
c0101d36:	e8 9b fd ff ff       	call   c0101ad6 <cons_intr>
c0101d3b:	83 c4 10             	add    $0x10,%esp
}
c0101d3e:	90                   	nop
c0101d3f:	c9                   	leave  
c0101d40:	c3                   	ret    

c0101d41 <kbd_init>:

static void
kbd_init(void) {
c0101d41:	55                   	push   %ebp
c0101d42:	89 e5                	mov    %esp,%ebp
c0101d44:	83 ec 08             	sub    $0x8,%esp
    // drain the kbd buffer
    kbd_intr();
c0101d47:	e8 dc ff ff ff       	call   c0101d28 <kbd_intr>
    pic_enable(IRQ_KBD);
c0101d4c:	83 ec 0c             	sub    $0xc,%esp
c0101d4f:	6a 01                	push   $0x1
c0101d51:	e8 4b 01 00 00       	call   c0101ea1 <pic_enable>
c0101d56:	83 c4 10             	add    $0x10,%esp
}
c0101d59:	90                   	nop
c0101d5a:	c9                   	leave  
c0101d5b:	c3                   	ret    

c0101d5c <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101d5c:	55                   	push   %ebp
c0101d5d:	89 e5                	mov    %esp,%ebp
c0101d5f:	83 ec 08             	sub    $0x8,%esp
    cga_init();
c0101d62:	e8 8c f8 ff ff       	call   c01015f3 <cga_init>
    serial_init();
c0101d67:	e8 6e f9 ff ff       	call   c01016da <serial_init>
    kbd_init();
c0101d6c:	e8 d0 ff ff ff       	call   c0101d41 <kbd_init>
    if (!serial_exists) {
c0101d71:	a1 28 75 12 c0       	mov    0xc0127528,%eax
c0101d76:	85 c0                	test   %eax,%eax
c0101d78:	75 10                	jne    c0101d8a <cons_init+0x2e>
        cprintf("serial port does not exist!!\n");
c0101d7a:	83 ec 0c             	sub    $0xc,%esp
c0101d7d:	68 a5 98 10 c0       	push   $0xc01098a5
c0101d82:	e8 03 e5 ff ff       	call   c010028a <cprintf>
c0101d87:	83 c4 10             	add    $0x10,%esp
    }
}
c0101d8a:	90                   	nop
c0101d8b:	c9                   	leave  
c0101d8c:	c3                   	ret    

c0101d8d <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101d8d:	55                   	push   %ebp
c0101d8e:	89 e5                	mov    %esp,%ebp
c0101d90:	83 ec 18             	sub    $0x18,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101d93:	e8 d4 f7 ff ff       	call   c010156c <__intr_save>
c0101d98:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101d9b:	83 ec 0c             	sub    $0xc,%esp
c0101d9e:	ff 75 08             	pushl  0x8(%ebp)
c0101da1:	e8 93 fa ff ff       	call   c0101839 <lpt_putc>
c0101da6:	83 c4 10             	add    $0x10,%esp
        cga_putc(c);
c0101da9:	83 ec 0c             	sub    $0xc,%esp
c0101dac:	ff 75 08             	pushl  0x8(%ebp)
c0101daf:	e8 bc fa ff ff       	call   c0101870 <cga_putc>
c0101db4:	83 c4 10             	add    $0x10,%esp
        serial_putc(c);
c0101db7:	83 ec 0c             	sub    $0xc,%esp
c0101dba:	ff 75 08             	pushl  0x8(%ebp)
c0101dbd:	e8 dd fc ff ff       	call   c0101a9f <serial_putc>
c0101dc2:	83 c4 10             	add    $0x10,%esp
    }
    local_intr_restore(intr_flag);
c0101dc5:	83 ec 0c             	sub    $0xc,%esp
c0101dc8:	ff 75 f4             	pushl  -0xc(%ebp)
c0101dcb:	e8 c6 f7 ff ff       	call   c0101596 <__intr_restore>
c0101dd0:	83 c4 10             	add    $0x10,%esp
}
c0101dd3:	90                   	nop
c0101dd4:	c9                   	leave  
c0101dd5:	c3                   	ret    

c0101dd6 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101dd6:	55                   	push   %ebp
c0101dd7:	89 e5                	mov    %esp,%ebp
c0101dd9:	83 ec 18             	sub    $0x18,%esp
    int c = 0;
c0101ddc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101de3:	e8 84 f7 ff ff       	call   c010156c <__intr_save>
c0101de8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101deb:	e8 89 fd ff ff       	call   c0101b79 <serial_intr>
        kbd_intr();
c0101df0:	e8 33 ff ff ff       	call   c0101d28 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101df5:	8b 15 40 77 12 c0    	mov    0xc0127740,%edx
c0101dfb:	a1 44 77 12 c0       	mov    0xc0127744,%eax
c0101e00:	39 c2                	cmp    %eax,%edx
c0101e02:	74 31                	je     c0101e35 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101e04:	a1 40 77 12 c0       	mov    0xc0127740,%eax
c0101e09:	8d 50 01             	lea    0x1(%eax),%edx
c0101e0c:	89 15 40 77 12 c0    	mov    %edx,0xc0127740
c0101e12:	0f b6 80 40 75 12 c0 	movzbl -0x3fed8ac0(%eax),%eax
c0101e19:	0f b6 c0             	movzbl %al,%eax
c0101e1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101e1f:	a1 40 77 12 c0       	mov    0xc0127740,%eax
c0101e24:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101e29:	75 0a                	jne    c0101e35 <cons_getc+0x5f>
                cons.rpos = 0;
c0101e2b:	c7 05 40 77 12 c0 00 	movl   $0x0,0xc0127740
c0101e32:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0101e35:	83 ec 0c             	sub    $0xc,%esp
c0101e38:	ff 75 f0             	pushl  -0x10(%ebp)
c0101e3b:	e8 56 f7 ff ff       	call   c0101596 <__intr_restore>
c0101e40:	83 c4 10             	add    $0x10,%esp
    return c;
c0101e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101e46:	c9                   	leave  
c0101e47:	c3                   	ret    

c0101e48 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101e48:	55                   	push   %ebp
c0101e49:	89 e5                	mov    %esp,%ebp
c0101e4b:	83 ec 14             	sub    $0x14,%esp
c0101e4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e51:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101e55:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101e59:	66 a3 50 45 12 c0    	mov    %ax,0xc0124550
    if (did_init) {
c0101e5f:	a1 4c 77 12 c0       	mov    0xc012774c,%eax
c0101e64:	85 c0                	test   %eax,%eax
c0101e66:	74 36                	je     c0101e9e <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c0101e68:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101e6c:	0f b6 c0             	movzbl %al,%eax
c0101e6f:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101e75:	88 45 fa             	mov    %al,-0x6(%ebp)
c0101e78:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
c0101e7c:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101e80:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0101e81:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101e85:	66 c1 e8 08          	shr    $0x8,%ax
c0101e89:	0f b6 c0             	movzbl %al,%eax
c0101e8c:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c0101e92:	88 45 fb             	mov    %al,-0x5(%ebp)
c0101e95:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
c0101e99:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101e9d:	ee                   	out    %al,(%dx)
    }
}
c0101e9e:	90                   	nop
c0101e9f:	c9                   	leave  
c0101ea0:	c3                   	ret    

c0101ea1 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101ea1:	55                   	push   %ebp
c0101ea2:	89 e5                	mov    %esp,%ebp
    pic_setmask(irq_mask & ~(1 << irq));
c0101ea4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ea7:	ba 01 00 00 00       	mov    $0x1,%edx
c0101eac:	89 c1                	mov    %eax,%ecx
c0101eae:	d3 e2                	shl    %cl,%edx
c0101eb0:	89 d0                	mov    %edx,%eax
c0101eb2:	f7 d0                	not    %eax
c0101eb4:	89 c2                	mov    %eax,%edx
c0101eb6:	0f b7 05 50 45 12 c0 	movzwl 0xc0124550,%eax
c0101ebd:	21 d0                	and    %edx,%eax
c0101ebf:	0f b7 c0             	movzwl %ax,%eax
c0101ec2:	50                   	push   %eax
c0101ec3:	e8 80 ff ff ff       	call   c0101e48 <pic_setmask>
c0101ec8:	83 c4 04             	add    $0x4,%esp
}
c0101ecb:	90                   	nop
c0101ecc:	c9                   	leave  
c0101ecd:	c3                   	ret    

c0101ece <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101ece:	55                   	push   %ebp
c0101ecf:	89 e5                	mov    %esp,%ebp
c0101ed1:	83 ec 30             	sub    $0x30,%esp
    did_init = 1;
c0101ed4:	c7 05 4c 77 12 c0 01 	movl   $0x1,0xc012774c
c0101edb:	00 00 00 
c0101ede:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101ee4:	c6 45 d6 ff          	movb   $0xff,-0x2a(%ebp)
c0101ee8:	0f b6 45 d6          	movzbl -0x2a(%ebp),%eax
c0101eec:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101ef0:	ee                   	out    %al,(%dx)
c0101ef1:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c0101ef7:	c6 45 d7 ff          	movb   $0xff,-0x29(%ebp)
c0101efb:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c0101eff:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101f03:	ee                   	out    %al,(%dx)
c0101f04:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
c0101f0a:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
c0101f0e:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c0101f12:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101f16:	ee                   	out    %al,(%dx)
c0101f17:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
c0101f1d:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
c0101f21:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101f25:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
c0101f29:	ee                   	out    %al,(%dx)
c0101f2a:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
c0101f30:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
c0101f34:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c0101f38:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101f3c:	ee                   	out    %al,(%dx)
c0101f3d:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
c0101f43:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
c0101f47:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0101f4b:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
c0101f4f:	ee                   	out    %al,(%dx)
c0101f50:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
c0101f56:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
c0101f5a:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0101f5e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f62:	ee                   	out    %al,(%dx)
c0101f63:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
c0101f69:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
c0101f6d:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101f71:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c0101f75:	ee                   	out    %al,(%dx)
c0101f76:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c0101f7c:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
c0101f80:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c0101f84:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101f88:	ee                   	out    %al,(%dx)
c0101f89:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
c0101f8f:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
c0101f93:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c0101f97:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
c0101f9b:	ee                   	out    %al,(%dx)
c0101f9c:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
c0101fa2:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
c0101fa6:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c0101faa:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101fae:	ee                   	out    %al,(%dx)
c0101faf:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
c0101fb5:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
c0101fb9:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101fbd:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c0101fc1:	ee                   	out    %al,(%dx)
c0101fc2:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c0101fc8:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
c0101fcc:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
c0101fd0:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101fd4:	ee                   	out    %al,(%dx)
c0101fd5:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
c0101fdb:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
c0101fdf:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
c0101fe3:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
c0101fe7:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0101fe8:	0f b7 05 50 45 12 c0 	movzwl 0xc0124550,%eax
c0101fef:	66 83 f8 ff          	cmp    $0xffff,%ax
c0101ff3:	74 13                	je     c0102008 <pic_init+0x13a>
        pic_setmask(irq_mask);
c0101ff5:	0f b7 05 50 45 12 c0 	movzwl 0xc0124550,%eax
c0101ffc:	0f b7 c0             	movzwl %ax,%eax
c0101fff:	50                   	push   %eax
c0102000:	e8 43 fe ff ff       	call   c0101e48 <pic_setmask>
c0102005:	83 c4 04             	add    $0x4,%esp
    }
}
c0102008:	90                   	nop
c0102009:	c9                   	leave  
c010200a:	c3                   	ret    

c010200b <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c010200b:	55                   	push   %ebp
c010200c:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c010200e:	fb                   	sti    
    sti();
}
c010200f:	90                   	nop
c0102010:	5d                   	pop    %ebp
c0102011:	c3                   	ret    

c0102012 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0102012:	55                   	push   %ebp
c0102013:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c0102015:	fa                   	cli    
    cli();
}
c0102016:	90                   	nop
c0102017:	5d                   	pop    %ebp
c0102018:	c3                   	ret    

c0102019 <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c0102019:	55                   	push   %ebp
c010201a:	89 e5                	mov    %esp,%ebp
c010201c:	83 ec 08             	sub    $0x8,%esp
    cprintf("%d ticks\n",TICK_NUM);
c010201f:	83 ec 08             	sub    $0x8,%esp
c0102022:	6a 64                	push   $0x64
c0102024:	68 e0 98 10 c0       	push   $0xc01098e0
c0102029:	e8 5c e2 ff ff       	call   c010028a <cprintf>
c010202e:	83 c4 10             	add    $0x10,%esp
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c0102031:	90                   	nop
c0102032:	c9                   	leave  
c0102033:	c3                   	ret    

c0102034 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0102034:	55                   	push   %ebp
c0102035:	89 e5                	mov    %esp,%ebp
c0102037:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c010203a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102041:	e9 c3 00 00 00       	jmp    c0102109 <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c0102046:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102049:	8b 04 85 e0 45 12 c0 	mov    -0x3fedba20(,%eax,4),%eax
c0102050:	89 c2                	mov    %eax,%edx
c0102052:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102055:	66 89 14 c5 60 77 12 	mov    %dx,-0x3fed88a0(,%eax,8)
c010205c:	c0 
c010205d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102060:	66 c7 04 c5 62 77 12 	movw   $0x8,-0x3fed889e(,%eax,8)
c0102067:	c0 08 00 
c010206a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010206d:	0f b6 14 c5 64 77 12 	movzbl -0x3fed889c(,%eax,8),%edx
c0102074:	c0 
c0102075:	83 e2 e0             	and    $0xffffffe0,%edx
c0102078:	88 14 c5 64 77 12 c0 	mov    %dl,-0x3fed889c(,%eax,8)
c010207f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102082:	0f b6 14 c5 64 77 12 	movzbl -0x3fed889c(,%eax,8),%edx
c0102089:	c0 
c010208a:	83 e2 1f             	and    $0x1f,%edx
c010208d:	88 14 c5 64 77 12 c0 	mov    %dl,-0x3fed889c(,%eax,8)
c0102094:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102097:	0f b6 14 c5 65 77 12 	movzbl -0x3fed889b(,%eax,8),%edx
c010209e:	c0 
c010209f:	83 e2 f0             	and    $0xfffffff0,%edx
c01020a2:	83 ca 0e             	or     $0xe,%edx
c01020a5:	88 14 c5 65 77 12 c0 	mov    %dl,-0x3fed889b(,%eax,8)
c01020ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01020af:	0f b6 14 c5 65 77 12 	movzbl -0x3fed889b(,%eax,8),%edx
c01020b6:	c0 
c01020b7:	83 e2 ef             	and    $0xffffffef,%edx
c01020ba:	88 14 c5 65 77 12 c0 	mov    %dl,-0x3fed889b(,%eax,8)
c01020c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01020c4:	0f b6 14 c5 65 77 12 	movzbl -0x3fed889b(,%eax,8),%edx
c01020cb:	c0 
c01020cc:	83 e2 9f             	and    $0xffffff9f,%edx
c01020cf:	88 14 c5 65 77 12 c0 	mov    %dl,-0x3fed889b(,%eax,8)
c01020d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01020d9:	0f b6 14 c5 65 77 12 	movzbl -0x3fed889b(,%eax,8),%edx
c01020e0:	c0 
c01020e1:	83 ca 80             	or     $0xffffff80,%edx
c01020e4:	88 14 c5 65 77 12 c0 	mov    %dl,-0x3fed889b(,%eax,8)
c01020eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01020ee:	8b 04 85 e0 45 12 c0 	mov    -0x3fedba20(,%eax,4),%eax
c01020f5:	c1 e8 10             	shr    $0x10,%eax
c01020f8:	89 c2                	mov    %eax,%edx
c01020fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01020fd:	66 89 14 c5 66 77 12 	mov    %dx,-0x3fed889a(,%eax,8)
c0102104:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c0102105:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0102109:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010210c:	3d ff 00 00 00       	cmp    $0xff,%eax
c0102111:	0f 86 2f ff ff ff    	jbe    c0102046 <idt_init+0x12>
c0102117:	c7 45 f8 60 45 12 c0 	movl   $0xc0124560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c010211e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102121:	0f 01 18             	lidtl  (%eax)
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    lidt(&idt_pd);
}
c0102124:	90                   	nop
c0102125:	c9                   	leave  
c0102126:	c3                   	ret    

c0102127 <trapname>:

static const char *
trapname(int trapno) {
c0102127:	55                   	push   %ebp
c0102128:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c010212a:	8b 45 08             	mov    0x8(%ebp),%eax
c010212d:	83 f8 13             	cmp    $0x13,%eax
c0102130:	77 0c                	ja     c010213e <trapname+0x17>
        return excnames[trapno];
c0102132:	8b 45 08             	mov    0x8(%ebp),%eax
c0102135:	8b 04 85 c0 9c 10 c0 	mov    -0x3fef6340(,%eax,4),%eax
c010213c:	eb 18                	jmp    c0102156 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c010213e:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0102142:	7e 0d                	jle    c0102151 <trapname+0x2a>
c0102144:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0102148:	7f 07                	jg     c0102151 <trapname+0x2a>
        return "Hardware Interrupt";
c010214a:	b8 ea 98 10 c0       	mov    $0xc01098ea,%eax
c010214f:	eb 05                	jmp    c0102156 <trapname+0x2f>
    }
    return "(unknown trap)";
c0102151:	b8 fd 98 10 c0       	mov    $0xc01098fd,%eax
}
c0102156:	5d                   	pop    %ebp
c0102157:	c3                   	ret    

c0102158 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0102158:	55                   	push   %ebp
c0102159:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c010215b:	8b 45 08             	mov    0x8(%ebp),%eax
c010215e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102162:	66 83 f8 08          	cmp    $0x8,%ax
c0102166:	0f 94 c0             	sete   %al
c0102169:	0f b6 c0             	movzbl %al,%eax
}
c010216c:	5d                   	pop    %ebp
c010216d:	c3                   	ret    

c010216e <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c010216e:	55                   	push   %ebp
c010216f:	89 e5                	mov    %esp,%ebp
c0102171:	83 ec 18             	sub    $0x18,%esp
    cprintf("trapframe at %p\n", tf);
c0102174:	83 ec 08             	sub    $0x8,%esp
c0102177:	ff 75 08             	pushl  0x8(%ebp)
c010217a:	68 3e 99 10 c0       	push   $0xc010993e
c010217f:	e8 06 e1 ff ff       	call   c010028a <cprintf>
c0102184:	83 c4 10             	add    $0x10,%esp
    print_regs(&tf->tf_regs);
c0102187:	8b 45 08             	mov    0x8(%ebp),%eax
c010218a:	83 ec 0c             	sub    $0xc,%esp
c010218d:	50                   	push   %eax
c010218e:	e8 b8 01 00 00       	call   c010234b <print_regs>
c0102193:	83 c4 10             	add    $0x10,%esp
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0102196:	8b 45 08             	mov    0x8(%ebp),%eax
c0102199:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010219d:	0f b7 c0             	movzwl %ax,%eax
c01021a0:	83 ec 08             	sub    $0x8,%esp
c01021a3:	50                   	push   %eax
c01021a4:	68 4f 99 10 c0       	push   $0xc010994f
c01021a9:	e8 dc e0 ff ff       	call   c010028a <cprintf>
c01021ae:	83 c4 10             	add    $0x10,%esp
    cprintf("  es   0x----%04x\n", tf->tf_es);
c01021b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01021b4:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c01021b8:	0f b7 c0             	movzwl %ax,%eax
c01021bb:	83 ec 08             	sub    $0x8,%esp
c01021be:	50                   	push   %eax
c01021bf:	68 62 99 10 c0       	push   $0xc0109962
c01021c4:	e8 c1 e0 ff ff       	call   c010028a <cprintf>
c01021c9:	83 c4 10             	add    $0x10,%esp
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c01021cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01021cf:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c01021d3:	0f b7 c0             	movzwl %ax,%eax
c01021d6:	83 ec 08             	sub    $0x8,%esp
c01021d9:	50                   	push   %eax
c01021da:	68 75 99 10 c0       	push   $0xc0109975
c01021df:	e8 a6 e0 ff ff       	call   c010028a <cprintf>
c01021e4:	83 c4 10             	add    $0x10,%esp
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c01021e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01021ea:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c01021ee:	0f b7 c0             	movzwl %ax,%eax
c01021f1:	83 ec 08             	sub    $0x8,%esp
c01021f4:	50                   	push   %eax
c01021f5:	68 88 99 10 c0       	push   $0xc0109988
c01021fa:	e8 8b e0 ff ff       	call   c010028a <cprintf>
c01021ff:	83 c4 10             	add    $0x10,%esp
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0102202:	8b 45 08             	mov    0x8(%ebp),%eax
c0102205:	8b 40 30             	mov    0x30(%eax),%eax
c0102208:	83 ec 0c             	sub    $0xc,%esp
c010220b:	50                   	push   %eax
c010220c:	e8 16 ff ff ff       	call   c0102127 <trapname>
c0102211:	83 c4 10             	add    $0x10,%esp
c0102214:	89 c2                	mov    %eax,%edx
c0102216:	8b 45 08             	mov    0x8(%ebp),%eax
c0102219:	8b 40 30             	mov    0x30(%eax),%eax
c010221c:	83 ec 04             	sub    $0x4,%esp
c010221f:	52                   	push   %edx
c0102220:	50                   	push   %eax
c0102221:	68 9b 99 10 c0       	push   $0xc010999b
c0102226:	e8 5f e0 ff ff       	call   c010028a <cprintf>
c010222b:	83 c4 10             	add    $0x10,%esp
    cprintf("  err  0x%08x\n", tf->tf_err);
c010222e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102231:	8b 40 34             	mov    0x34(%eax),%eax
c0102234:	83 ec 08             	sub    $0x8,%esp
c0102237:	50                   	push   %eax
c0102238:	68 ad 99 10 c0       	push   $0xc01099ad
c010223d:	e8 48 e0 ff ff       	call   c010028a <cprintf>
c0102242:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0102245:	8b 45 08             	mov    0x8(%ebp),%eax
c0102248:	8b 40 38             	mov    0x38(%eax),%eax
c010224b:	83 ec 08             	sub    $0x8,%esp
c010224e:	50                   	push   %eax
c010224f:	68 bc 99 10 c0       	push   $0xc01099bc
c0102254:	e8 31 e0 ff ff       	call   c010028a <cprintf>
c0102259:	83 c4 10             	add    $0x10,%esp
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c010225c:	8b 45 08             	mov    0x8(%ebp),%eax
c010225f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102263:	0f b7 c0             	movzwl %ax,%eax
c0102266:	83 ec 08             	sub    $0x8,%esp
c0102269:	50                   	push   %eax
c010226a:	68 cb 99 10 c0       	push   $0xc01099cb
c010226f:	e8 16 e0 ff ff       	call   c010028a <cprintf>
c0102274:	83 c4 10             	add    $0x10,%esp
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0102277:	8b 45 08             	mov    0x8(%ebp),%eax
c010227a:	8b 40 40             	mov    0x40(%eax),%eax
c010227d:	83 ec 08             	sub    $0x8,%esp
c0102280:	50                   	push   %eax
c0102281:	68 de 99 10 c0       	push   $0xc01099de
c0102286:	e8 ff df ff ff       	call   c010028a <cprintf>
c010228b:	83 c4 10             	add    $0x10,%esp

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c010228e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102295:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c010229c:	eb 3f                	jmp    c01022dd <print_trapframe+0x16f>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c010229e:	8b 45 08             	mov    0x8(%ebp),%eax
c01022a1:	8b 50 40             	mov    0x40(%eax),%edx
c01022a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01022a7:	21 d0                	and    %edx,%eax
c01022a9:	85 c0                	test   %eax,%eax
c01022ab:	74 29                	je     c01022d6 <print_trapframe+0x168>
c01022ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01022b0:	8b 04 85 80 45 12 c0 	mov    -0x3fedba80(,%eax,4),%eax
c01022b7:	85 c0                	test   %eax,%eax
c01022b9:	74 1b                	je     c01022d6 <print_trapframe+0x168>
            cprintf("%s,", IA32flags[i]);
c01022bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01022be:	8b 04 85 80 45 12 c0 	mov    -0x3fedba80(,%eax,4),%eax
c01022c5:	83 ec 08             	sub    $0x8,%esp
c01022c8:	50                   	push   %eax
c01022c9:	68 ed 99 10 c0       	push   $0xc01099ed
c01022ce:	e8 b7 df ff ff       	call   c010028a <cprintf>
c01022d3:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01022d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01022da:	d1 65 f0             	shll   -0x10(%ebp)
c01022dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01022e0:	83 f8 17             	cmp    $0x17,%eax
c01022e3:	76 b9                	jbe    c010229e <print_trapframe+0x130>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c01022e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01022e8:	8b 40 40             	mov    0x40(%eax),%eax
c01022eb:	25 00 30 00 00       	and    $0x3000,%eax
c01022f0:	c1 e8 0c             	shr    $0xc,%eax
c01022f3:	83 ec 08             	sub    $0x8,%esp
c01022f6:	50                   	push   %eax
c01022f7:	68 f1 99 10 c0       	push   $0xc01099f1
c01022fc:	e8 89 df ff ff       	call   c010028a <cprintf>
c0102301:	83 c4 10             	add    $0x10,%esp

    if (!trap_in_kernel(tf)) {
c0102304:	83 ec 0c             	sub    $0xc,%esp
c0102307:	ff 75 08             	pushl  0x8(%ebp)
c010230a:	e8 49 fe ff ff       	call   c0102158 <trap_in_kernel>
c010230f:	83 c4 10             	add    $0x10,%esp
c0102312:	85 c0                	test   %eax,%eax
c0102314:	75 32                	jne    c0102348 <print_trapframe+0x1da>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0102316:	8b 45 08             	mov    0x8(%ebp),%eax
c0102319:	8b 40 44             	mov    0x44(%eax),%eax
c010231c:	83 ec 08             	sub    $0x8,%esp
c010231f:	50                   	push   %eax
c0102320:	68 fa 99 10 c0       	push   $0xc01099fa
c0102325:	e8 60 df ff ff       	call   c010028a <cprintf>
c010232a:	83 c4 10             	add    $0x10,%esp
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c010232d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102330:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0102334:	0f b7 c0             	movzwl %ax,%eax
c0102337:	83 ec 08             	sub    $0x8,%esp
c010233a:	50                   	push   %eax
c010233b:	68 09 9a 10 c0       	push   $0xc0109a09
c0102340:	e8 45 df ff ff       	call   c010028a <cprintf>
c0102345:	83 c4 10             	add    $0x10,%esp
    }
}
c0102348:	90                   	nop
c0102349:	c9                   	leave  
c010234a:	c3                   	ret    

c010234b <print_regs>:

void
print_regs(struct pushregs *regs) {
c010234b:	55                   	push   %ebp
c010234c:	89 e5                	mov    %esp,%ebp
c010234e:	83 ec 08             	sub    $0x8,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0102351:	8b 45 08             	mov    0x8(%ebp),%eax
c0102354:	8b 00                	mov    (%eax),%eax
c0102356:	83 ec 08             	sub    $0x8,%esp
c0102359:	50                   	push   %eax
c010235a:	68 1c 9a 10 c0       	push   $0xc0109a1c
c010235f:	e8 26 df ff ff       	call   c010028a <cprintf>
c0102364:	83 c4 10             	add    $0x10,%esp
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0102367:	8b 45 08             	mov    0x8(%ebp),%eax
c010236a:	8b 40 04             	mov    0x4(%eax),%eax
c010236d:	83 ec 08             	sub    $0x8,%esp
c0102370:	50                   	push   %eax
c0102371:	68 2b 9a 10 c0       	push   $0xc0109a2b
c0102376:	e8 0f df ff ff       	call   c010028a <cprintf>
c010237b:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c010237e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102381:	8b 40 08             	mov    0x8(%eax),%eax
c0102384:	83 ec 08             	sub    $0x8,%esp
c0102387:	50                   	push   %eax
c0102388:	68 3a 9a 10 c0       	push   $0xc0109a3a
c010238d:	e8 f8 de ff ff       	call   c010028a <cprintf>
c0102392:	83 c4 10             	add    $0x10,%esp
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0102395:	8b 45 08             	mov    0x8(%ebp),%eax
c0102398:	8b 40 0c             	mov    0xc(%eax),%eax
c010239b:	83 ec 08             	sub    $0x8,%esp
c010239e:	50                   	push   %eax
c010239f:	68 49 9a 10 c0       	push   $0xc0109a49
c01023a4:	e8 e1 de ff ff       	call   c010028a <cprintf>
c01023a9:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c01023ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01023af:	8b 40 10             	mov    0x10(%eax),%eax
c01023b2:	83 ec 08             	sub    $0x8,%esp
c01023b5:	50                   	push   %eax
c01023b6:	68 58 9a 10 c0       	push   $0xc0109a58
c01023bb:	e8 ca de ff ff       	call   c010028a <cprintf>
c01023c0:	83 c4 10             	add    $0x10,%esp
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c01023c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01023c6:	8b 40 14             	mov    0x14(%eax),%eax
c01023c9:	83 ec 08             	sub    $0x8,%esp
c01023cc:	50                   	push   %eax
c01023cd:	68 67 9a 10 c0       	push   $0xc0109a67
c01023d2:	e8 b3 de ff ff       	call   c010028a <cprintf>
c01023d7:	83 c4 10             	add    $0x10,%esp
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c01023da:	8b 45 08             	mov    0x8(%ebp),%eax
c01023dd:	8b 40 18             	mov    0x18(%eax),%eax
c01023e0:	83 ec 08             	sub    $0x8,%esp
c01023e3:	50                   	push   %eax
c01023e4:	68 76 9a 10 c0       	push   $0xc0109a76
c01023e9:	e8 9c de ff ff       	call   c010028a <cprintf>
c01023ee:	83 c4 10             	add    $0x10,%esp
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c01023f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01023f4:	8b 40 1c             	mov    0x1c(%eax),%eax
c01023f7:	83 ec 08             	sub    $0x8,%esp
c01023fa:	50                   	push   %eax
c01023fb:	68 85 9a 10 c0       	push   $0xc0109a85
c0102400:	e8 85 de ff ff       	call   c010028a <cprintf>
c0102405:	83 c4 10             	add    $0x10,%esp
}
c0102408:	90                   	nop
c0102409:	c9                   	leave  
c010240a:	c3                   	ret    

c010240b <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c010240b:	55                   	push   %ebp
c010240c:	89 e5                	mov    %esp,%ebp
c010240e:	53                   	push   %ebx
c010240f:	83 ec 14             	sub    $0x14,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c0102412:	8b 45 08             	mov    0x8(%ebp),%eax
c0102415:	8b 40 34             	mov    0x34(%eax),%eax
c0102418:	83 e0 01             	and    $0x1,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010241b:	85 c0                	test   %eax,%eax
c010241d:	74 07                	je     c0102426 <print_pgfault+0x1b>
c010241f:	bb 94 9a 10 c0       	mov    $0xc0109a94,%ebx
c0102424:	eb 05                	jmp    c010242b <print_pgfault+0x20>
c0102426:	bb a5 9a 10 c0       	mov    $0xc0109aa5,%ebx
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
c010242b:	8b 45 08             	mov    0x8(%ebp),%eax
c010242e:	8b 40 34             	mov    0x34(%eax),%eax
c0102431:	83 e0 02             	and    $0x2,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102434:	85 c0                	test   %eax,%eax
c0102436:	74 07                	je     c010243f <print_pgfault+0x34>
c0102438:	b9 57 00 00 00       	mov    $0x57,%ecx
c010243d:	eb 05                	jmp    c0102444 <print_pgfault+0x39>
c010243f:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c0102444:	8b 45 08             	mov    0x8(%ebp),%eax
c0102447:	8b 40 34             	mov    0x34(%eax),%eax
c010244a:	83 e0 04             	and    $0x4,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010244d:	85 c0                	test   %eax,%eax
c010244f:	74 07                	je     c0102458 <print_pgfault+0x4d>
c0102451:	ba 55 00 00 00       	mov    $0x55,%edx
c0102456:	eb 05                	jmp    c010245d <print_pgfault+0x52>
c0102458:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c010245d:	0f 20 d0             	mov    %cr2,%eax
c0102460:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c0102463:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102466:	83 ec 0c             	sub    $0xc,%esp
c0102469:	53                   	push   %ebx
c010246a:	51                   	push   %ecx
c010246b:	52                   	push   %edx
c010246c:	50                   	push   %eax
c010246d:	68 b4 9a 10 c0       	push   $0xc0109ab4
c0102472:	e8 13 de ff ff       	call   c010028a <cprintf>
c0102477:	83 c4 20             	add    $0x20,%esp
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
}
c010247a:	90                   	nop
c010247b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010247e:	c9                   	leave  
c010247f:	c3                   	ret    

c0102480 <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c0102480:	55                   	push   %ebp
c0102481:	89 e5                	mov    %esp,%ebp
c0102483:	83 ec 18             	sub    $0x18,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c0102486:	83 ec 0c             	sub    $0xc,%esp
c0102489:	ff 75 08             	pushl  0x8(%ebp)
c010248c:	e8 7a ff ff ff       	call   c010240b <print_pgfault>
c0102491:	83 c4 10             	add    $0x10,%esp
    if (check_mm_struct != NULL) {
c0102494:	a1 58 a0 12 c0       	mov    0xc012a058,%eax
c0102499:	85 c0                	test   %eax,%eax
c010249b:	74 24                	je     c01024c1 <pgfault_handler+0x41>
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c010249d:	0f 20 d0             	mov    %cr2,%eax
c01024a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c01024a3:	8b 4d f4             	mov    -0xc(%ebp),%ecx
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c01024a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01024a9:	8b 50 34             	mov    0x34(%eax),%edx
c01024ac:	a1 58 a0 12 c0       	mov    0xc012a058,%eax
c01024b1:	83 ec 04             	sub    $0x4,%esp
c01024b4:	51                   	push   %ecx
c01024b5:	52                   	push   %edx
c01024b6:	50                   	push   %eax
c01024b7:	e8 58 16 00 00       	call   c0103b14 <do_pgfault>
c01024bc:	83 c4 10             	add    $0x10,%esp
c01024bf:	eb 17                	jmp    c01024d8 <pgfault_handler+0x58>
    }
    panic("unhandled page fault.\n");
c01024c1:	83 ec 04             	sub    $0x4,%esp
c01024c4:	68 d7 9a 10 c0       	push   $0xc0109ad7
c01024c9:	68 a5 00 00 00       	push   $0xa5
c01024ce:	68 ee 9a 10 c0       	push   $0xc0109aee
c01024d3:	e8 18 df ff ff       	call   c01003f0 <__panic>
}
c01024d8:	c9                   	leave  
c01024d9:	c3                   	ret    

c01024da <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c01024da:	55                   	push   %ebp
c01024db:	89 e5                	mov    %esp,%ebp
c01024dd:	83 ec 18             	sub    $0x18,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c01024e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01024e3:	8b 40 30             	mov    0x30(%eax),%eax
c01024e6:	83 f8 24             	cmp    $0x24,%eax
c01024e9:	0f 84 ba 00 00 00    	je     c01025a9 <trap_dispatch+0xcf>
c01024ef:	83 f8 24             	cmp    $0x24,%eax
c01024f2:	77 18                	ja     c010250c <trap_dispatch+0x32>
c01024f4:	83 f8 20             	cmp    $0x20,%eax
c01024f7:	74 76                	je     c010256f <trap_dispatch+0x95>
c01024f9:	83 f8 21             	cmp    $0x21,%eax
c01024fc:	0f 84 cb 00 00 00    	je     c01025cd <trap_dispatch+0xf3>
c0102502:	83 f8 0e             	cmp    $0xe,%eax
c0102505:	74 28                	je     c010252f <trap_dispatch+0x55>
c0102507:	e9 fc 00 00 00       	jmp    c0102608 <trap_dispatch+0x12e>
c010250c:	83 f8 2e             	cmp    $0x2e,%eax
c010250f:	0f 82 f3 00 00 00    	jb     c0102608 <trap_dispatch+0x12e>
c0102515:	83 f8 2f             	cmp    $0x2f,%eax
c0102518:	0f 86 20 01 00 00    	jbe    c010263e <trap_dispatch+0x164>
c010251e:	83 e8 78             	sub    $0x78,%eax
c0102521:	83 f8 01             	cmp    $0x1,%eax
c0102524:	0f 87 de 00 00 00    	ja     c0102608 <trap_dispatch+0x12e>
c010252a:	e9 c2 00 00 00       	jmp    c01025f1 <trap_dispatch+0x117>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c010252f:	83 ec 0c             	sub    $0xc,%esp
c0102532:	ff 75 08             	pushl  0x8(%ebp)
c0102535:	e8 46 ff ff ff       	call   c0102480 <pgfault_handler>
c010253a:	83 c4 10             	add    $0x10,%esp
c010253d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102540:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102544:	0f 84 f7 00 00 00    	je     c0102641 <trap_dispatch+0x167>
            print_trapframe(tf);
c010254a:	83 ec 0c             	sub    $0xc,%esp
c010254d:	ff 75 08             	pushl  0x8(%ebp)
c0102550:	e8 19 fc ff ff       	call   c010216e <print_trapframe>
c0102555:	83 c4 10             	add    $0x10,%esp
            panic("handle pgfault failed. %e\n", ret);
c0102558:	ff 75 f4             	pushl  -0xc(%ebp)
c010255b:	68 ff 9a 10 c0       	push   $0xc0109aff
c0102560:	68 b5 00 00 00       	push   $0xb5
c0102565:	68 ee 9a 10 c0       	push   $0xc0109aee
c010256a:	e8 81 de ff ff       	call   c01003f0 <__panic>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c010256f:	a1 54 a0 12 c0       	mov    0xc012a054,%eax
c0102574:	83 c0 01             	add    $0x1,%eax
c0102577:	a3 54 a0 12 c0       	mov    %eax,0xc012a054
        if (ticks % TICK_NUM == 0) {
c010257c:	8b 0d 54 a0 12 c0    	mov    0xc012a054,%ecx
c0102582:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0102587:	89 c8                	mov    %ecx,%eax
c0102589:	f7 e2                	mul    %edx
c010258b:	89 d0                	mov    %edx,%eax
c010258d:	c1 e8 05             	shr    $0x5,%eax
c0102590:	6b c0 64             	imul   $0x64,%eax,%eax
c0102593:	29 c1                	sub    %eax,%ecx
c0102595:	89 c8                	mov    %ecx,%eax
c0102597:	85 c0                	test   %eax,%eax
c0102599:	0f 85 a5 00 00 00    	jne    c0102644 <trap_dispatch+0x16a>
            print_ticks();
c010259f:	e8 75 fa ff ff       	call   c0102019 <print_ticks>
        }
        break;
c01025a4:	e9 9b 00 00 00       	jmp    c0102644 <trap_dispatch+0x16a>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c01025a9:	e8 28 f8 ff ff       	call   c0101dd6 <cons_getc>
c01025ae:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c01025b1:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c01025b5:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c01025b9:	83 ec 04             	sub    $0x4,%esp
c01025bc:	52                   	push   %edx
c01025bd:	50                   	push   %eax
c01025be:	68 1a 9b 10 c0       	push   $0xc0109b1a
c01025c3:	e8 c2 dc ff ff       	call   c010028a <cprintf>
c01025c8:	83 c4 10             	add    $0x10,%esp
        break;
c01025cb:	eb 78                	jmp    c0102645 <trap_dispatch+0x16b>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c01025cd:	e8 04 f8 ff ff       	call   c0101dd6 <cons_getc>
c01025d2:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c01025d5:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c01025d9:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c01025dd:	83 ec 04             	sub    $0x4,%esp
c01025e0:	52                   	push   %edx
c01025e1:	50                   	push   %eax
c01025e2:	68 2c 9b 10 c0       	push   $0xc0109b2c
c01025e7:	e8 9e dc ff ff       	call   c010028a <cprintf>
c01025ec:	83 c4 10             	add    $0x10,%esp
        break;
c01025ef:	eb 54                	jmp    c0102645 <trap_dispatch+0x16b>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c01025f1:	83 ec 04             	sub    $0x4,%esp
c01025f4:	68 3b 9b 10 c0       	push   $0xc0109b3b
c01025f9:	68 d3 00 00 00       	push   $0xd3
c01025fe:	68 ee 9a 10 c0       	push   $0xc0109aee
c0102603:	e8 e8 dd ff ff       	call   c01003f0 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0102608:	8b 45 08             	mov    0x8(%ebp),%eax
c010260b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010260f:	0f b7 c0             	movzwl %ax,%eax
c0102612:	83 e0 03             	and    $0x3,%eax
c0102615:	85 c0                	test   %eax,%eax
c0102617:	75 2c                	jne    c0102645 <trap_dispatch+0x16b>
            print_trapframe(tf);
c0102619:	83 ec 0c             	sub    $0xc,%esp
c010261c:	ff 75 08             	pushl  0x8(%ebp)
c010261f:	e8 4a fb ff ff       	call   c010216e <print_trapframe>
c0102624:	83 c4 10             	add    $0x10,%esp
            panic("unexpected trap in kernel.\n");
c0102627:	83 ec 04             	sub    $0x4,%esp
c010262a:	68 4b 9b 10 c0       	push   $0xc0109b4b
c010262f:	68 dd 00 00 00       	push   $0xdd
c0102634:	68 ee 9a 10 c0       	push   $0xc0109aee
c0102639:	e8 b2 dd ff ff       	call   c01003f0 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c010263e:	90                   	nop
c010263f:	eb 04                	jmp    c0102645 <trap_dispatch+0x16b>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
            print_trapframe(tf);
            panic("handle pgfault failed. %e\n", ret);
        }
        break;
c0102641:	90                   	nop
c0102642:	eb 01                	jmp    c0102645 <trap_dispatch+0x16b>
         */
        ticks ++;
        if (ticks % TICK_NUM == 0) {
            print_ticks();
        }
        break;
c0102644:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c0102645:	90                   	nop
c0102646:	c9                   	leave  
c0102647:	c3                   	ret    

c0102648 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0102648:	55                   	push   %ebp
c0102649:	89 e5                	mov    %esp,%ebp
c010264b:	83 ec 08             	sub    $0x8,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c010264e:	83 ec 0c             	sub    $0xc,%esp
c0102651:	ff 75 08             	pushl  0x8(%ebp)
c0102654:	e8 81 fe ff ff       	call   c01024da <trap_dispatch>
c0102659:	83 c4 10             	add    $0x10,%esp
}
c010265c:	90                   	nop
c010265d:	c9                   	leave  
c010265e:	c3                   	ret    

c010265f <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c010265f:	6a 00                	push   $0x0
  pushl $0
c0102661:	6a 00                	push   $0x0
  jmp __alltraps
c0102663:	e9 67 0a 00 00       	jmp    c01030cf <__alltraps>

c0102668 <vector1>:
.globl vector1
vector1:
  pushl $0
c0102668:	6a 00                	push   $0x0
  pushl $1
c010266a:	6a 01                	push   $0x1
  jmp __alltraps
c010266c:	e9 5e 0a 00 00       	jmp    c01030cf <__alltraps>

c0102671 <vector2>:
.globl vector2
vector2:
  pushl $0
c0102671:	6a 00                	push   $0x0
  pushl $2
c0102673:	6a 02                	push   $0x2
  jmp __alltraps
c0102675:	e9 55 0a 00 00       	jmp    c01030cf <__alltraps>

c010267a <vector3>:
.globl vector3
vector3:
  pushl $0
c010267a:	6a 00                	push   $0x0
  pushl $3
c010267c:	6a 03                	push   $0x3
  jmp __alltraps
c010267e:	e9 4c 0a 00 00       	jmp    c01030cf <__alltraps>

c0102683 <vector4>:
.globl vector4
vector4:
  pushl $0
c0102683:	6a 00                	push   $0x0
  pushl $4
c0102685:	6a 04                	push   $0x4
  jmp __alltraps
c0102687:	e9 43 0a 00 00       	jmp    c01030cf <__alltraps>

c010268c <vector5>:
.globl vector5
vector5:
  pushl $0
c010268c:	6a 00                	push   $0x0
  pushl $5
c010268e:	6a 05                	push   $0x5
  jmp __alltraps
c0102690:	e9 3a 0a 00 00       	jmp    c01030cf <__alltraps>

c0102695 <vector6>:
.globl vector6
vector6:
  pushl $0
c0102695:	6a 00                	push   $0x0
  pushl $6
c0102697:	6a 06                	push   $0x6
  jmp __alltraps
c0102699:	e9 31 0a 00 00       	jmp    c01030cf <__alltraps>

c010269e <vector7>:
.globl vector7
vector7:
  pushl $0
c010269e:	6a 00                	push   $0x0
  pushl $7
c01026a0:	6a 07                	push   $0x7
  jmp __alltraps
c01026a2:	e9 28 0a 00 00       	jmp    c01030cf <__alltraps>

c01026a7 <vector8>:
.globl vector8
vector8:
  pushl $8
c01026a7:	6a 08                	push   $0x8
  jmp __alltraps
c01026a9:	e9 21 0a 00 00       	jmp    c01030cf <__alltraps>

c01026ae <vector9>:
.globl vector9
vector9:
  pushl $9
c01026ae:	6a 09                	push   $0x9
  jmp __alltraps
c01026b0:	e9 1a 0a 00 00       	jmp    c01030cf <__alltraps>

c01026b5 <vector10>:
.globl vector10
vector10:
  pushl $10
c01026b5:	6a 0a                	push   $0xa
  jmp __alltraps
c01026b7:	e9 13 0a 00 00       	jmp    c01030cf <__alltraps>

c01026bc <vector11>:
.globl vector11
vector11:
  pushl $11
c01026bc:	6a 0b                	push   $0xb
  jmp __alltraps
c01026be:	e9 0c 0a 00 00       	jmp    c01030cf <__alltraps>

c01026c3 <vector12>:
.globl vector12
vector12:
  pushl $12
c01026c3:	6a 0c                	push   $0xc
  jmp __alltraps
c01026c5:	e9 05 0a 00 00       	jmp    c01030cf <__alltraps>

c01026ca <vector13>:
.globl vector13
vector13:
  pushl $13
c01026ca:	6a 0d                	push   $0xd
  jmp __alltraps
c01026cc:	e9 fe 09 00 00       	jmp    c01030cf <__alltraps>

c01026d1 <vector14>:
.globl vector14
vector14:
  pushl $14
c01026d1:	6a 0e                	push   $0xe
  jmp __alltraps
c01026d3:	e9 f7 09 00 00       	jmp    c01030cf <__alltraps>

c01026d8 <vector15>:
.globl vector15
vector15:
  pushl $0
c01026d8:	6a 00                	push   $0x0
  pushl $15
c01026da:	6a 0f                	push   $0xf
  jmp __alltraps
c01026dc:	e9 ee 09 00 00       	jmp    c01030cf <__alltraps>

c01026e1 <vector16>:
.globl vector16
vector16:
  pushl $0
c01026e1:	6a 00                	push   $0x0
  pushl $16
c01026e3:	6a 10                	push   $0x10
  jmp __alltraps
c01026e5:	e9 e5 09 00 00       	jmp    c01030cf <__alltraps>

c01026ea <vector17>:
.globl vector17
vector17:
  pushl $17
c01026ea:	6a 11                	push   $0x11
  jmp __alltraps
c01026ec:	e9 de 09 00 00       	jmp    c01030cf <__alltraps>

c01026f1 <vector18>:
.globl vector18
vector18:
  pushl $0
c01026f1:	6a 00                	push   $0x0
  pushl $18
c01026f3:	6a 12                	push   $0x12
  jmp __alltraps
c01026f5:	e9 d5 09 00 00       	jmp    c01030cf <__alltraps>

c01026fa <vector19>:
.globl vector19
vector19:
  pushl $0
c01026fa:	6a 00                	push   $0x0
  pushl $19
c01026fc:	6a 13                	push   $0x13
  jmp __alltraps
c01026fe:	e9 cc 09 00 00       	jmp    c01030cf <__alltraps>

c0102703 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102703:	6a 00                	push   $0x0
  pushl $20
c0102705:	6a 14                	push   $0x14
  jmp __alltraps
c0102707:	e9 c3 09 00 00       	jmp    c01030cf <__alltraps>

c010270c <vector21>:
.globl vector21
vector21:
  pushl $0
c010270c:	6a 00                	push   $0x0
  pushl $21
c010270e:	6a 15                	push   $0x15
  jmp __alltraps
c0102710:	e9 ba 09 00 00       	jmp    c01030cf <__alltraps>

c0102715 <vector22>:
.globl vector22
vector22:
  pushl $0
c0102715:	6a 00                	push   $0x0
  pushl $22
c0102717:	6a 16                	push   $0x16
  jmp __alltraps
c0102719:	e9 b1 09 00 00       	jmp    c01030cf <__alltraps>

c010271e <vector23>:
.globl vector23
vector23:
  pushl $0
c010271e:	6a 00                	push   $0x0
  pushl $23
c0102720:	6a 17                	push   $0x17
  jmp __alltraps
c0102722:	e9 a8 09 00 00       	jmp    c01030cf <__alltraps>

c0102727 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102727:	6a 00                	push   $0x0
  pushl $24
c0102729:	6a 18                	push   $0x18
  jmp __alltraps
c010272b:	e9 9f 09 00 00       	jmp    c01030cf <__alltraps>

c0102730 <vector25>:
.globl vector25
vector25:
  pushl $0
c0102730:	6a 00                	push   $0x0
  pushl $25
c0102732:	6a 19                	push   $0x19
  jmp __alltraps
c0102734:	e9 96 09 00 00       	jmp    c01030cf <__alltraps>

c0102739 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102739:	6a 00                	push   $0x0
  pushl $26
c010273b:	6a 1a                	push   $0x1a
  jmp __alltraps
c010273d:	e9 8d 09 00 00       	jmp    c01030cf <__alltraps>

c0102742 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102742:	6a 00                	push   $0x0
  pushl $27
c0102744:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102746:	e9 84 09 00 00       	jmp    c01030cf <__alltraps>

c010274b <vector28>:
.globl vector28
vector28:
  pushl $0
c010274b:	6a 00                	push   $0x0
  pushl $28
c010274d:	6a 1c                	push   $0x1c
  jmp __alltraps
c010274f:	e9 7b 09 00 00       	jmp    c01030cf <__alltraps>

c0102754 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102754:	6a 00                	push   $0x0
  pushl $29
c0102756:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102758:	e9 72 09 00 00       	jmp    c01030cf <__alltraps>

c010275d <vector30>:
.globl vector30
vector30:
  pushl $0
c010275d:	6a 00                	push   $0x0
  pushl $30
c010275f:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102761:	e9 69 09 00 00       	jmp    c01030cf <__alltraps>

c0102766 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102766:	6a 00                	push   $0x0
  pushl $31
c0102768:	6a 1f                	push   $0x1f
  jmp __alltraps
c010276a:	e9 60 09 00 00       	jmp    c01030cf <__alltraps>

c010276f <vector32>:
.globl vector32
vector32:
  pushl $0
c010276f:	6a 00                	push   $0x0
  pushl $32
c0102771:	6a 20                	push   $0x20
  jmp __alltraps
c0102773:	e9 57 09 00 00       	jmp    c01030cf <__alltraps>

c0102778 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102778:	6a 00                	push   $0x0
  pushl $33
c010277a:	6a 21                	push   $0x21
  jmp __alltraps
c010277c:	e9 4e 09 00 00       	jmp    c01030cf <__alltraps>

c0102781 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102781:	6a 00                	push   $0x0
  pushl $34
c0102783:	6a 22                	push   $0x22
  jmp __alltraps
c0102785:	e9 45 09 00 00       	jmp    c01030cf <__alltraps>

c010278a <vector35>:
.globl vector35
vector35:
  pushl $0
c010278a:	6a 00                	push   $0x0
  pushl $35
c010278c:	6a 23                	push   $0x23
  jmp __alltraps
c010278e:	e9 3c 09 00 00       	jmp    c01030cf <__alltraps>

c0102793 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102793:	6a 00                	push   $0x0
  pushl $36
c0102795:	6a 24                	push   $0x24
  jmp __alltraps
c0102797:	e9 33 09 00 00       	jmp    c01030cf <__alltraps>

c010279c <vector37>:
.globl vector37
vector37:
  pushl $0
c010279c:	6a 00                	push   $0x0
  pushl $37
c010279e:	6a 25                	push   $0x25
  jmp __alltraps
c01027a0:	e9 2a 09 00 00       	jmp    c01030cf <__alltraps>

c01027a5 <vector38>:
.globl vector38
vector38:
  pushl $0
c01027a5:	6a 00                	push   $0x0
  pushl $38
c01027a7:	6a 26                	push   $0x26
  jmp __alltraps
c01027a9:	e9 21 09 00 00       	jmp    c01030cf <__alltraps>

c01027ae <vector39>:
.globl vector39
vector39:
  pushl $0
c01027ae:	6a 00                	push   $0x0
  pushl $39
c01027b0:	6a 27                	push   $0x27
  jmp __alltraps
c01027b2:	e9 18 09 00 00       	jmp    c01030cf <__alltraps>

c01027b7 <vector40>:
.globl vector40
vector40:
  pushl $0
c01027b7:	6a 00                	push   $0x0
  pushl $40
c01027b9:	6a 28                	push   $0x28
  jmp __alltraps
c01027bb:	e9 0f 09 00 00       	jmp    c01030cf <__alltraps>

c01027c0 <vector41>:
.globl vector41
vector41:
  pushl $0
c01027c0:	6a 00                	push   $0x0
  pushl $41
c01027c2:	6a 29                	push   $0x29
  jmp __alltraps
c01027c4:	e9 06 09 00 00       	jmp    c01030cf <__alltraps>

c01027c9 <vector42>:
.globl vector42
vector42:
  pushl $0
c01027c9:	6a 00                	push   $0x0
  pushl $42
c01027cb:	6a 2a                	push   $0x2a
  jmp __alltraps
c01027cd:	e9 fd 08 00 00       	jmp    c01030cf <__alltraps>

c01027d2 <vector43>:
.globl vector43
vector43:
  pushl $0
c01027d2:	6a 00                	push   $0x0
  pushl $43
c01027d4:	6a 2b                	push   $0x2b
  jmp __alltraps
c01027d6:	e9 f4 08 00 00       	jmp    c01030cf <__alltraps>

c01027db <vector44>:
.globl vector44
vector44:
  pushl $0
c01027db:	6a 00                	push   $0x0
  pushl $44
c01027dd:	6a 2c                	push   $0x2c
  jmp __alltraps
c01027df:	e9 eb 08 00 00       	jmp    c01030cf <__alltraps>

c01027e4 <vector45>:
.globl vector45
vector45:
  pushl $0
c01027e4:	6a 00                	push   $0x0
  pushl $45
c01027e6:	6a 2d                	push   $0x2d
  jmp __alltraps
c01027e8:	e9 e2 08 00 00       	jmp    c01030cf <__alltraps>

c01027ed <vector46>:
.globl vector46
vector46:
  pushl $0
c01027ed:	6a 00                	push   $0x0
  pushl $46
c01027ef:	6a 2e                	push   $0x2e
  jmp __alltraps
c01027f1:	e9 d9 08 00 00       	jmp    c01030cf <__alltraps>

c01027f6 <vector47>:
.globl vector47
vector47:
  pushl $0
c01027f6:	6a 00                	push   $0x0
  pushl $47
c01027f8:	6a 2f                	push   $0x2f
  jmp __alltraps
c01027fa:	e9 d0 08 00 00       	jmp    c01030cf <__alltraps>

c01027ff <vector48>:
.globl vector48
vector48:
  pushl $0
c01027ff:	6a 00                	push   $0x0
  pushl $48
c0102801:	6a 30                	push   $0x30
  jmp __alltraps
c0102803:	e9 c7 08 00 00       	jmp    c01030cf <__alltraps>

c0102808 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102808:	6a 00                	push   $0x0
  pushl $49
c010280a:	6a 31                	push   $0x31
  jmp __alltraps
c010280c:	e9 be 08 00 00       	jmp    c01030cf <__alltraps>

c0102811 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102811:	6a 00                	push   $0x0
  pushl $50
c0102813:	6a 32                	push   $0x32
  jmp __alltraps
c0102815:	e9 b5 08 00 00       	jmp    c01030cf <__alltraps>

c010281a <vector51>:
.globl vector51
vector51:
  pushl $0
c010281a:	6a 00                	push   $0x0
  pushl $51
c010281c:	6a 33                	push   $0x33
  jmp __alltraps
c010281e:	e9 ac 08 00 00       	jmp    c01030cf <__alltraps>

c0102823 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102823:	6a 00                	push   $0x0
  pushl $52
c0102825:	6a 34                	push   $0x34
  jmp __alltraps
c0102827:	e9 a3 08 00 00       	jmp    c01030cf <__alltraps>

c010282c <vector53>:
.globl vector53
vector53:
  pushl $0
c010282c:	6a 00                	push   $0x0
  pushl $53
c010282e:	6a 35                	push   $0x35
  jmp __alltraps
c0102830:	e9 9a 08 00 00       	jmp    c01030cf <__alltraps>

c0102835 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102835:	6a 00                	push   $0x0
  pushl $54
c0102837:	6a 36                	push   $0x36
  jmp __alltraps
c0102839:	e9 91 08 00 00       	jmp    c01030cf <__alltraps>

c010283e <vector55>:
.globl vector55
vector55:
  pushl $0
c010283e:	6a 00                	push   $0x0
  pushl $55
c0102840:	6a 37                	push   $0x37
  jmp __alltraps
c0102842:	e9 88 08 00 00       	jmp    c01030cf <__alltraps>

c0102847 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102847:	6a 00                	push   $0x0
  pushl $56
c0102849:	6a 38                	push   $0x38
  jmp __alltraps
c010284b:	e9 7f 08 00 00       	jmp    c01030cf <__alltraps>

c0102850 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102850:	6a 00                	push   $0x0
  pushl $57
c0102852:	6a 39                	push   $0x39
  jmp __alltraps
c0102854:	e9 76 08 00 00       	jmp    c01030cf <__alltraps>

c0102859 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102859:	6a 00                	push   $0x0
  pushl $58
c010285b:	6a 3a                	push   $0x3a
  jmp __alltraps
c010285d:	e9 6d 08 00 00       	jmp    c01030cf <__alltraps>

c0102862 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102862:	6a 00                	push   $0x0
  pushl $59
c0102864:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102866:	e9 64 08 00 00       	jmp    c01030cf <__alltraps>

c010286b <vector60>:
.globl vector60
vector60:
  pushl $0
c010286b:	6a 00                	push   $0x0
  pushl $60
c010286d:	6a 3c                	push   $0x3c
  jmp __alltraps
c010286f:	e9 5b 08 00 00       	jmp    c01030cf <__alltraps>

c0102874 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102874:	6a 00                	push   $0x0
  pushl $61
c0102876:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102878:	e9 52 08 00 00       	jmp    c01030cf <__alltraps>

c010287d <vector62>:
.globl vector62
vector62:
  pushl $0
c010287d:	6a 00                	push   $0x0
  pushl $62
c010287f:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102881:	e9 49 08 00 00       	jmp    c01030cf <__alltraps>

c0102886 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102886:	6a 00                	push   $0x0
  pushl $63
c0102888:	6a 3f                	push   $0x3f
  jmp __alltraps
c010288a:	e9 40 08 00 00       	jmp    c01030cf <__alltraps>

c010288f <vector64>:
.globl vector64
vector64:
  pushl $0
c010288f:	6a 00                	push   $0x0
  pushl $64
c0102891:	6a 40                	push   $0x40
  jmp __alltraps
c0102893:	e9 37 08 00 00       	jmp    c01030cf <__alltraps>

c0102898 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102898:	6a 00                	push   $0x0
  pushl $65
c010289a:	6a 41                	push   $0x41
  jmp __alltraps
c010289c:	e9 2e 08 00 00       	jmp    c01030cf <__alltraps>

c01028a1 <vector66>:
.globl vector66
vector66:
  pushl $0
c01028a1:	6a 00                	push   $0x0
  pushl $66
c01028a3:	6a 42                	push   $0x42
  jmp __alltraps
c01028a5:	e9 25 08 00 00       	jmp    c01030cf <__alltraps>

c01028aa <vector67>:
.globl vector67
vector67:
  pushl $0
c01028aa:	6a 00                	push   $0x0
  pushl $67
c01028ac:	6a 43                	push   $0x43
  jmp __alltraps
c01028ae:	e9 1c 08 00 00       	jmp    c01030cf <__alltraps>

c01028b3 <vector68>:
.globl vector68
vector68:
  pushl $0
c01028b3:	6a 00                	push   $0x0
  pushl $68
c01028b5:	6a 44                	push   $0x44
  jmp __alltraps
c01028b7:	e9 13 08 00 00       	jmp    c01030cf <__alltraps>

c01028bc <vector69>:
.globl vector69
vector69:
  pushl $0
c01028bc:	6a 00                	push   $0x0
  pushl $69
c01028be:	6a 45                	push   $0x45
  jmp __alltraps
c01028c0:	e9 0a 08 00 00       	jmp    c01030cf <__alltraps>

c01028c5 <vector70>:
.globl vector70
vector70:
  pushl $0
c01028c5:	6a 00                	push   $0x0
  pushl $70
c01028c7:	6a 46                	push   $0x46
  jmp __alltraps
c01028c9:	e9 01 08 00 00       	jmp    c01030cf <__alltraps>

c01028ce <vector71>:
.globl vector71
vector71:
  pushl $0
c01028ce:	6a 00                	push   $0x0
  pushl $71
c01028d0:	6a 47                	push   $0x47
  jmp __alltraps
c01028d2:	e9 f8 07 00 00       	jmp    c01030cf <__alltraps>

c01028d7 <vector72>:
.globl vector72
vector72:
  pushl $0
c01028d7:	6a 00                	push   $0x0
  pushl $72
c01028d9:	6a 48                	push   $0x48
  jmp __alltraps
c01028db:	e9 ef 07 00 00       	jmp    c01030cf <__alltraps>

c01028e0 <vector73>:
.globl vector73
vector73:
  pushl $0
c01028e0:	6a 00                	push   $0x0
  pushl $73
c01028e2:	6a 49                	push   $0x49
  jmp __alltraps
c01028e4:	e9 e6 07 00 00       	jmp    c01030cf <__alltraps>

c01028e9 <vector74>:
.globl vector74
vector74:
  pushl $0
c01028e9:	6a 00                	push   $0x0
  pushl $74
c01028eb:	6a 4a                	push   $0x4a
  jmp __alltraps
c01028ed:	e9 dd 07 00 00       	jmp    c01030cf <__alltraps>

c01028f2 <vector75>:
.globl vector75
vector75:
  pushl $0
c01028f2:	6a 00                	push   $0x0
  pushl $75
c01028f4:	6a 4b                	push   $0x4b
  jmp __alltraps
c01028f6:	e9 d4 07 00 00       	jmp    c01030cf <__alltraps>

c01028fb <vector76>:
.globl vector76
vector76:
  pushl $0
c01028fb:	6a 00                	push   $0x0
  pushl $76
c01028fd:	6a 4c                	push   $0x4c
  jmp __alltraps
c01028ff:	e9 cb 07 00 00       	jmp    c01030cf <__alltraps>

c0102904 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102904:	6a 00                	push   $0x0
  pushl $77
c0102906:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102908:	e9 c2 07 00 00       	jmp    c01030cf <__alltraps>

c010290d <vector78>:
.globl vector78
vector78:
  pushl $0
c010290d:	6a 00                	push   $0x0
  pushl $78
c010290f:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102911:	e9 b9 07 00 00       	jmp    c01030cf <__alltraps>

c0102916 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102916:	6a 00                	push   $0x0
  pushl $79
c0102918:	6a 4f                	push   $0x4f
  jmp __alltraps
c010291a:	e9 b0 07 00 00       	jmp    c01030cf <__alltraps>

c010291f <vector80>:
.globl vector80
vector80:
  pushl $0
c010291f:	6a 00                	push   $0x0
  pushl $80
c0102921:	6a 50                	push   $0x50
  jmp __alltraps
c0102923:	e9 a7 07 00 00       	jmp    c01030cf <__alltraps>

c0102928 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102928:	6a 00                	push   $0x0
  pushl $81
c010292a:	6a 51                	push   $0x51
  jmp __alltraps
c010292c:	e9 9e 07 00 00       	jmp    c01030cf <__alltraps>

c0102931 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102931:	6a 00                	push   $0x0
  pushl $82
c0102933:	6a 52                	push   $0x52
  jmp __alltraps
c0102935:	e9 95 07 00 00       	jmp    c01030cf <__alltraps>

c010293a <vector83>:
.globl vector83
vector83:
  pushl $0
c010293a:	6a 00                	push   $0x0
  pushl $83
c010293c:	6a 53                	push   $0x53
  jmp __alltraps
c010293e:	e9 8c 07 00 00       	jmp    c01030cf <__alltraps>

c0102943 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102943:	6a 00                	push   $0x0
  pushl $84
c0102945:	6a 54                	push   $0x54
  jmp __alltraps
c0102947:	e9 83 07 00 00       	jmp    c01030cf <__alltraps>

c010294c <vector85>:
.globl vector85
vector85:
  pushl $0
c010294c:	6a 00                	push   $0x0
  pushl $85
c010294e:	6a 55                	push   $0x55
  jmp __alltraps
c0102950:	e9 7a 07 00 00       	jmp    c01030cf <__alltraps>

c0102955 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102955:	6a 00                	push   $0x0
  pushl $86
c0102957:	6a 56                	push   $0x56
  jmp __alltraps
c0102959:	e9 71 07 00 00       	jmp    c01030cf <__alltraps>

c010295e <vector87>:
.globl vector87
vector87:
  pushl $0
c010295e:	6a 00                	push   $0x0
  pushl $87
c0102960:	6a 57                	push   $0x57
  jmp __alltraps
c0102962:	e9 68 07 00 00       	jmp    c01030cf <__alltraps>

c0102967 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102967:	6a 00                	push   $0x0
  pushl $88
c0102969:	6a 58                	push   $0x58
  jmp __alltraps
c010296b:	e9 5f 07 00 00       	jmp    c01030cf <__alltraps>

c0102970 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102970:	6a 00                	push   $0x0
  pushl $89
c0102972:	6a 59                	push   $0x59
  jmp __alltraps
c0102974:	e9 56 07 00 00       	jmp    c01030cf <__alltraps>

c0102979 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102979:	6a 00                	push   $0x0
  pushl $90
c010297b:	6a 5a                	push   $0x5a
  jmp __alltraps
c010297d:	e9 4d 07 00 00       	jmp    c01030cf <__alltraps>

c0102982 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102982:	6a 00                	push   $0x0
  pushl $91
c0102984:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102986:	e9 44 07 00 00       	jmp    c01030cf <__alltraps>

c010298b <vector92>:
.globl vector92
vector92:
  pushl $0
c010298b:	6a 00                	push   $0x0
  pushl $92
c010298d:	6a 5c                	push   $0x5c
  jmp __alltraps
c010298f:	e9 3b 07 00 00       	jmp    c01030cf <__alltraps>

c0102994 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102994:	6a 00                	push   $0x0
  pushl $93
c0102996:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102998:	e9 32 07 00 00       	jmp    c01030cf <__alltraps>

c010299d <vector94>:
.globl vector94
vector94:
  pushl $0
c010299d:	6a 00                	push   $0x0
  pushl $94
c010299f:	6a 5e                	push   $0x5e
  jmp __alltraps
c01029a1:	e9 29 07 00 00       	jmp    c01030cf <__alltraps>

c01029a6 <vector95>:
.globl vector95
vector95:
  pushl $0
c01029a6:	6a 00                	push   $0x0
  pushl $95
c01029a8:	6a 5f                	push   $0x5f
  jmp __alltraps
c01029aa:	e9 20 07 00 00       	jmp    c01030cf <__alltraps>

c01029af <vector96>:
.globl vector96
vector96:
  pushl $0
c01029af:	6a 00                	push   $0x0
  pushl $96
c01029b1:	6a 60                	push   $0x60
  jmp __alltraps
c01029b3:	e9 17 07 00 00       	jmp    c01030cf <__alltraps>

c01029b8 <vector97>:
.globl vector97
vector97:
  pushl $0
c01029b8:	6a 00                	push   $0x0
  pushl $97
c01029ba:	6a 61                	push   $0x61
  jmp __alltraps
c01029bc:	e9 0e 07 00 00       	jmp    c01030cf <__alltraps>

c01029c1 <vector98>:
.globl vector98
vector98:
  pushl $0
c01029c1:	6a 00                	push   $0x0
  pushl $98
c01029c3:	6a 62                	push   $0x62
  jmp __alltraps
c01029c5:	e9 05 07 00 00       	jmp    c01030cf <__alltraps>

c01029ca <vector99>:
.globl vector99
vector99:
  pushl $0
c01029ca:	6a 00                	push   $0x0
  pushl $99
c01029cc:	6a 63                	push   $0x63
  jmp __alltraps
c01029ce:	e9 fc 06 00 00       	jmp    c01030cf <__alltraps>

c01029d3 <vector100>:
.globl vector100
vector100:
  pushl $0
c01029d3:	6a 00                	push   $0x0
  pushl $100
c01029d5:	6a 64                	push   $0x64
  jmp __alltraps
c01029d7:	e9 f3 06 00 00       	jmp    c01030cf <__alltraps>

c01029dc <vector101>:
.globl vector101
vector101:
  pushl $0
c01029dc:	6a 00                	push   $0x0
  pushl $101
c01029de:	6a 65                	push   $0x65
  jmp __alltraps
c01029e0:	e9 ea 06 00 00       	jmp    c01030cf <__alltraps>

c01029e5 <vector102>:
.globl vector102
vector102:
  pushl $0
c01029e5:	6a 00                	push   $0x0
  pushl $102
c01029e7:	6a 66                	push   $0x66
  jmp __alltraps
c01029e9:	e9 e1 06 00 00       	jmp    c01030cf <__alltraps>

c01029ee <vector103>:
.globl vector103
vector103:
  pushl $0
c01029ee:	6a 00                	push   $0x0
  pushl $103
c01029f0:	6a 67                	push   $0x67
  jmp __alltraps
c01029f2:	e9 d8 06 00 00       	jmp    c01030cf <__alltraps>

c01029f7 <vector104>:
.globl vector104
vector104:
  pushl $0
c01029f7:	6a 00                	push   $0x0
  pushl $104
c01029f9:	6a 68                	push   $0x68
  jmp __alltraps
c01029fb:	e9 cf 06 00 00       	jmp    c01030cf <__alltraps>

c0102a00 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102a00:	6a 00                	push   $0x0
  pushl $105
c0102a02:	6a 69                	push   $0x69
  jmp __alltraps
c0102a04:	e9 c6 06 00 00       	jmp    c01030cf <__alltraps>

c0102a09 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102a09:	6a 00                	push   $0x0
  pushl $106
c0102a0b:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102a0d:	e9 bd 06 00 00       	jmp    c01030cf <__alltraps>

c0102a12 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102a12:	6a 00                	push   $0x0
  pushl $107
c0102a14:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102a16:	e9 b4 06 00 00       	jmp    c01030cf <__alltraps>

c0102a1b <vector108>:
.globl vector108
vector108:
  pushl $0
c0102a1b:	6a 00                	push   $0x0
  pushl $108
c0102a1d:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102a1f:	e9 ab 06 00 00       	jmp    c01030cf <__alltraps>

c0102a24 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102a24:	6a 00                	push   $0x0
  pushl $109
c0102a26:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102a28:	e9 a2 06 00 00       	jmp    c01030cf <__alltraps>

c0102a2d <vector110>:
.globl vector110
vector110:
  pushl $0
c0102a2d:	6a 00                	push   $0x0
  pushl $110
c0102a2f:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102a31:	e9 99 06 00 00       	jmp    c01030cf <__alltraps>

c0102a36 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102a36:	6a 00                	push   $0x0
  pushl $111
c0102a38:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102a3a:	e9 90 06 00 00       	jmp    c01030cf <__alltraps>

c0102a3f <vector112>:
.globl vector112
vector112:
  pushl $0
c0102a3f:	6a 00                	push   $0x0
  pushl $112
c0102a41:	6a 70                	push   $0x70
  jmp __alltraps
c0102a43:	e9 87 06 00 00       	jmp    c01030cf <__alltraps>

c0102a48 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102a48:	6a 00                	push   $0x0
  pushl $113
c0102a4a:	6a 71                	push   $0x71
  jmp __alltraps
c0102a4c:	e9 7e 06 00 00       	jmp    c01030cf <__alltraps>

c0102a51 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102a51:	6a 00                	push   $0x0
  pushl $114
c0102a53:	6a 72                	push   $0x72
  jmp __alltraps
c0102a55:	e9 75 06 00 00       	jmp    c01030cf <__alltraps>

c0102a5a <vector115>:
.globl vector115
vector115:
  pushl $0
c0102a5a:	6a 00                	push   $0x0
  pushl $115
c0102a5c:	6a 73                	push   $0x73
  jmp __alltraps
c0102a5e:	e9 6c 06 00 00       	jmp    c01030cf <__alltraps>

c0102a63 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102a63:	6a 00                	push   $0x0
  pushl $116
c0102a65:	6a 74                	push   $0x74
  jmp __alltraps
c0102a67:	e9 63 06 00 00       	jmp    c01030cf <__alltraps>

c0102a6c <vector117>:
.globl vector117
vector117:
  pushl $0
c0102a6c:	6a 00                	push   $0x0
  pushl $117
c0102a6e:	6a 75                	push   $0x75
  jmp __alltraps
c0102a70:	e9 5a 06 00 00       	jmp    c01030cf <__alltraps>

c0102a75 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102a75:	6a 00                	push   $0x0
  pushl $118
c0102a77:	6a 76                	push   $0x76
  jmp __alltraps
c0102a79:	e9 51 06 00 00       	jmp    c01030cf <__alltraps>

c0102a7e <vector119>:
.globl vector119
vector119:
  pushl $0
c0102a7e:	6a 00                	push   $0x0
  pushl $119
c0102a80:	6a 77                	push   $0x77
  jmp __alltraps
c0102a82:	e9 48 06 00 00       	jmp    c01030cf <__alltraps>

c0102a87 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102a87:	6a 00                	push   $0x0
  pushl $120
c0102a89:	6a 78                	push   $0x78
  jmp __alltraps
c0102a8b:	e9 3f 06 00 00       	jmp    c01030cf <__alltraps>

c0102a90 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102a90:	6a 00                	push   $0x0
  pushl $121
c0102a92:	6a 79                	push   $0x79
  jmp __alltraps
c0102a94:	e9 36 06 00 00       	jmp    c01030cf <__alltraps>

c0102a99 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102a99:	6a 00                	push   $0x0
  pushl $122
c0102a9b:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102a9d:	e9 2d 06 00 00       	jmp    c01030cf <__alltraps>

c0102aa2 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102aa2:	6a 00                	push   $0x0
  pushl $123
c0102aa4:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102aa6:	e9 24 06 00 00       	jmp    c01030cf <__alltraps>

c0102aab <vector124>:
.globl vector124
vector124:
  pushl $0
c0102aab:	6a 00                	push   $0x0
  pushl $124
c0102aad:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102aaf:	e9 1b 06 00 00       	jmp    c01030cf <__alltraps>

c0102ab4 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102ab4:	6a 00                	push   $0x0
  pushl $125
c0102ab6:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102ab8:	e9 12 06 00 00       	jmp    c01030cf <__alltraps>

c0102abd <vector126>:
.globl vector126
vector126:
  pushl $0
c0102abd:	6a 00                	push   $0x0
  pushl $126
c0102abf:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102ac1:	e9 09 06 00 00       	jmp    c01030cf <__alltraps>

c0102ac6 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102ac6:	6a 00                	push   $0x0
  pushl $127
c0102ac8:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102aca:	e9 00 06 00 00       	jmp    c01030cf <__alltraps>

c0102acf <vector128>:
.globl vector128
vector128:
  pushl $0
c0102acf:	6a 00                	push   $0x0
  pushl $128
c0102ad1:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102ad6:	e9 f4 05 00 00       	jmp    c01030cf <__alltraps>

c0102adb <vector129>:
.globl vector129
vector129:
  pushl $0
c0102adb:	6a 00                	push   $0x0
  pushl $129
c0102add:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102ae2:	e9 e8 05 00 00       	jmp    c01030cf <__alltraps>

c0102ae7 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102ae7:	6a 00                	push   $0x0
  pushl $130
c0102ae9:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102aee:	e9 dc 05 00 00       	jmp    c01030cf <__alltraps>

c0102af3 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102af3:	6a 00                	push   $0x0
  pushl $131
c0102af5:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102afa:	e9 d0 05 00 00       	jmp    c01030cf <__alltraps>

c0102aff <vector132>:
.globl vector132
vector132:
  pushl $0
c0102aff:	6a 00                	push   $0x0
  pushl $132
c0102b01:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102b06:	e9 c4 05 00 00       	jmp    c01030cf <__alltraps>

c0102b0b <vector133>:
.globl vector133
vector133:
  pushl $0
c0102b0b:	6a 00                	push   $0x0
  pushl $133
c0102b0d:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102b12:	e9 b8 05 00 00       	jmp    c01030cf <__alltraps>

c0102b17 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102b17:	6a 00                	push   $0x0
  pushl $134
c0102b19:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102b1e:	e9 ac 05 00 00       	jmp    c01030cf <__alltraps>

c0102b23 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102b23:	6a 00                	push   $0x0
  pushl $135
c0102b25:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102b2a:	e9 a0 05 00 00       	jmp    c01030cf <__alltraps>

c0102b2f <vector136>:
.globl vector136
vector136:
  pushl $0
c0102b2f:	6a 00                	push   $0x0
  pushl $136
c0102b31:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102b36:	e9 94 05 00 00       	jmp    c01030cf <__alltraps>

c0102b3b <vector137>:
.globl vector137
vector137:
  pushl $0
c0102b3b:	6a 00                	push   $0x0
  pushl $137
c0102b3d:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102b42:	e9 88 05 00 00       	jmp    c01030cf <__alltraps>

c0102b47 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102b47:	6a 00                	push   $0x0
  pushl $138
c0102b49:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102b4e:	e9 7c 05 00 00       	jmp    c01030cf <__alltraps>

c0102b53 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102b53:	6a 00                	push   $0x0
  pushl $139
c0102b55:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102b5a:	e9 70 05 00 00       	jmp    c01030cf <__alltraps>

c0102b5f <vector140>:
.globl vector140
vector140:
  pushl $0
c0102b5f:	6a 00                	push   $0x0
  pushl $140
c0102b61:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102b66:	e9 64 05 00 00       	jmp    c01030cf <__alltraps>

c0102b6b <vector141>:
.globl vector141
vector141:
  pushl $0
c0102b6b:	6a 00                	push   $0x0
  pushl $141
c0102b6d:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102b72:	e9 58 05 00 00       	jmp    c01030cf <__alltraps>

c0102b77 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102b77:	6a 00                	push   $0x0
  pushl $142
c0102b79:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102b7e:	e9 4c 05 00 00       	jmp    c01030cf <__alltraps>

c0102b83 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102b83:	6a 00                	push   $0x0
  pushl $143
c0102b85:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102b8a:	e9 40 05 00 00       	jmp    c01030cf <__alltraps>

c0102b8f <vector144>:
.globl vector144
vector144:
  pushl $0
c0102b8f:	6a 00                	push   $0x0
  pushl $144
c0102b91:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102b96:	e9 34 05 00 00       	jmp    c01030cf <__alltraps>

c0102b9b <vector145>:
.globl vector145
vector145:
  pushl $0
c0102b9b:	6a 00                	push   $0x0
  pushl $145
c0102b9d:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102ba2:	e9 28 05 00 00       	jmp    c01030cf <__alltraps>

c0102ba7 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102ba7:	6a 00                	push   $0x0
  pushl $146
c0102ba9:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102bae:	e9 1c 05 00 00       	jmp    c01030cf <__alltraps>

c0102bb3 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102bb3:	6a 00                	push   $0x0
  pushl $147
c0102bb5:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102bba:	e9 10 05 00 00       	jmp    c01030cf <__alltraps>

c0102bbf <vector148>:
.globl vector148
vector148:
  pushl $0
c0102bbf:	6a 00                	push   $0x0
  pushl $148
c0102bc1:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102bc6:	e9 04 05 00 00       	jmp    c01030cf <__alltraps>

c0102bcb <vector149>:
.globl vector149
vector149:
  pushl $0
c0102bcb:	6a 00                	push   $0x0
  pushl $149
c0102bcd:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102bd2:	e9 f8 04 00 00       	jmp    c01030cf <__alltraps>

c0102bd7 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102bd7:	6a 00                	push   $0x0
  pushl $150
c0102bd9:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102bde:	e9 ec 04 00 00       	jmp    c01030cf <__alltraps>

c0102be3 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102be3:	6a 00                	push   $0x0
  pushl $151
c0102be5:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102bea:	e9 e0 04 00 00       	jmp    c01030cf <__alltraps>

c0102bef <vector152>:
.globl vector152
vector152:
  pushl $0
c0102bef:	6a 00                	push   $0x0
  pushl $152
c0102bf1:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102bf6:	e9 d4 04 00 00       	jmp    c01030cf <__alltraps>

c0102bfb <vector153>:
.globl vector153
vector153:
  pushl $0
c0102bfb:	6a 00                	push   $0x0
  pushl $153
c0102bfd:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102c02:	e9 c8 04 00 00       	jmp    c01030cf <__alltraps>

c0102c07 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102c07:	6a 00                	push   $0x0
  pushl $154
c0102c09:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102c0e:	e9 bc 04 00 00       	jmp    c01030cf <__alltraps>

c0102c13 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102c13:	6a 00                	push   $0x0
  pushl $155
c0102c15:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102c1a:	e9 b0 04 00 00       	jmp    c01030cf <__alltraps>

c0102c1f <vector156>:
.globl vector156
vector156:
  pushl $0
c0102c1f:	6a 00                	push   $0x0
  pushl $156
c0102c21:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102c26:	e9 a4 04 00 00       	jmp    c01030cf <__alltraps>

c0102c2b <vector157>:
.globl vector157
vector157:
  pushl $0
c0102c2b:	6a 00                	push   $0x0
  pushl $157
c0102c2d:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102c32:	e9 98 04 00 00       	jmp    c01030cf <__alltraps>

c0102c37 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102c37:	6a 00                	push   $0x0
  pushl $158
c0102c39:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102c3e:	e9 8c 04 00 00       	jmp    c01030cf <__alltraps>

c0102c43 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102c43:	6a 00                	push   $0x0
  pushl $159
c0102c45:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102c4a:	e9 80 04 00 00       	jmp    c01030cf <__alltraps>

c0102c4f <vector160>:
.globl vector160
vector160:
  pushl $0
c0102c4f:	6a 00                	push   $0x0
  pushl $160
c0102c51:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102c56:	e9 74 04 00 00       	jmp    c01030cf <__alltraps>

c0102c5b <vector161>:
.globl vector161
vector161:
  pushl $0
c0102c5b:	6a 00                	push   $0x0
  pushl $161
c0102c5d:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102c62:	e9 68 04 00 00       	jmp    c01030cf <__alltraps>

c0102c67 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102c67:	6a 00                	push   $0x0
  pushl $162
c0102c69:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102c6e:	e9 5c 04 00 00       	jmp    c01030cf <__alltraps>

c0102c73 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102c73:	6a 00                	push   $0x0
  pushl $163
c0102c75:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102c7a:	e9 50 04 00 00       	jmp    c01030cf <__alltraps>

c0102c7f <vector164>:
.globl vector164
vector164:
  pushl $0
c0102c7f:	6a 00                	push   $0x0
  pushl $164
c0102c81:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102c86:	e9 44 04 00 00       	jmp    c01030cf <__alltraps>

c0102c8b <vector165>:
.globl vector165
vector165:
  pushl $0
c0102c8b:	6a 00                	push   $0x0
  pushl $165
c0102c8d:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102c92:	e9 38 04 00 00       	jmp    c01030cf <__alltraps>

c0102c97 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102c97:	6a 00                	push   $0x0
  pushl $166
c0102c99:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102c9e:	e9 2c 04 00 00       	jmp    c01030cf <__alltraps>

c0102ca3 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102ca3:	6a 00                	push   $0x0
  pushl $167
c0102ca5:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102caa:	e9 20 04 00 00       	jmp    c01030cf <__alltraps>

c0102caf <vector168>:
.globl vector168
vector168:
  pushl $0
c0102caf:	6a 00                	push   $0x0
  pushl $168
c0102cb1:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102cb6:	e9 14 04 00 00       	jmp    c01030cf <__alltraps>

c0102cbb <vector169>:
.globl vector169
vector169:
  pushl $0
c0102cbb:	6a 00                	push   $0x0
  pushl $169
c0102cbd:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102cc2:	e9 08 04 00 00       	jmp    c01030cf <__alltraps>

c0102cc7 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102cc7:	6a 00                	push   $0x0
  pushl $170
c0102cc9:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102cce:	e9 fc 03 00 00       	jmp    c01030cf <__alltraps>

c0102cd3 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102cd3:	6a 00                	push   $0x0
  pushl $171
c0102cd5:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102cda:	e9 f0 03 00 00       	jmp    c01030cf <__alltraps>

c0102cdf <vector172>:
.globl vector172
vector172:
  pushl $0
c0102cdf:	6a 00                	push   $0x0
  pushl $172
c0102ce1:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102ce6:	e9 e4 03 00 00       	jmp    c01030cf <__alltraps>

c0102ceb <vector173>:
.globl vector173
vector173:
  pushl $0
c0102ceb:	6a 00                	push   $0x0
  pushl $173
c0102ced:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102cf2:	e9 d8 03 00 00       	jmp    c01030cf <__alltraps>

c0102cf7 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102cf7:	6a 00                	push   $0x0
  pushl $174
c0102cf9:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102cfe:	e9 cc 03 00 00       	jmp    c01030cf <__alltraps>

c0102d03 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102d03:	6a 00                	push   $0x0
  pushl $175
c0102d05:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102d0a:	e9 c0 03 00 00       	jmp    c01030cf <__alltraps>

c0102d0f <vector176>:
.globl vector176
vector176:
  pushl $0
c0102d0f:	6a 00                	push   $0x0
  pushl $176
c0102d11:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102d16:	e9 b4 03 00 00       	jmp    c01030cf <__alltraps>

c0102d1b <vector177>:
.globl vector177
vector177:
  pushl $0
c0102d1b:	6a 00                	push   $0x0
  pushl $177
c0102d1d:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102d22:	e9 a8 03 00 00       	jmp    c01030cf <__alltraps>

c0102d27 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102d27:	6a 00                	push   $0x0
  pushl $178
c0102d29:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102d2e:	e9 9c 03 00 00       	jmp    c01030cf <__alltraps>

c0102d33 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102d33:	6a 00                	push   $0x0
  pushl $179
c0102d35:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102d3a:	e9 90 03 00 00       	jmp    c01030cf <__alltraps>

c0102d3f <vector180>:
.globl vector180
vector180:
  pushl $0
c0102d3f:	6a 00                	push   $0x0
  pushl $180
c0102d41:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102d46:	e9 84 03 00 00       	jmp    c01030cf <__alltraps>

c0102d4b <vector181>:
.globl vector181
vector181:
  pushl $0
c0102d4b:	6a 00                	push   $0x0
  pushl $181
c0102d4d:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102d52:	e9 78 03 00 00       	jmp    c01030cf <__alltraps>

c0102d57 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102d57:	6a 00                	push   $0x0
  pushl $182
c0102d59:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102d5e:	e9 6c 03 00 00       	jmp    c01030cf <__alltraps>

c0102d63 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102d63:	6a 00                	push   $0x0
  pushl $183
c0102d65:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102d6a:	e9 60 03 00 00       	jmp    c01030cf <__alltraps>

c0102d6f <vector184>:
.globl vector184
vector184:
  pushl $0
c0102d6f:	6a 00                	push   $0x0
  pushl $184
c0102d71:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102d76:	e9 54 03 00 00       	jmp    c01030cf <__alltraps>

c0102d7b <vector185>:
.globl vector185
vector185:
  pushl $0
c0102d7b:	6a 00                	push   $0x0
  pushl $185
c0102d7d:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102d82:	e9 48 03 00 00       	jmp    c01030cf <__alltraps>

c0102d87 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102d87:	6a 00                	push   $0x0
  pushl $186
c0102d89:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102d8e:	e9 3c 03 00 00       	jmp    c01030cf <__alltraps>

c0102d93 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102d93:	6a 00                	push   $0x0
  pushl $187
c0102d95:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102d9a:	e9 30 03 00 00       	jmp    c01030cf <__alltraps>

c0102d9f <vector188>:
.globl vector188
vector188:
  pushl $0
c0102d9f:	6a 00                	push   $0x0
  pushl $188
c0102da1:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102da6:	e9 24 03 00 00       	jmp    c01030cf <__alltraps>

c0102dab <vector189>:
.globl vector189
vector189:
  pushl $0
c0102dab:	6a 00                	push   $0x0
  pushl $189
c0102dad:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102db2:	e9 18 03 00 00       	jmp    c01030cf <__alltraps>

c0102db7 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102db7:	6a 00                	push   $0x0
  pushl $190
c0102db9:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102dbe:	e9 0c 03 00 00       	jmp    c01030cf <__alltraps>

c0102dc3 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102dc3:	6a 00                	push   $0x0
  pushl $191
c0102dc5:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102dca:	e9 00 03 00 00       	jmp    c01030cf <__alltraps>

c0102dcf <vector192>:
.globl vector192
vector192:
  pushl $0
c0102dcf:	6a 00                	push   $0x0
  pushl $192
c0102dd1:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102dd6:	e9 f4 02 00 00       	jmp    c01030cf <__alltraps>

c0102ddb <vector193>:
.globl vector193
vector193:
  pushl $0
c0102ddb:	6a 00                	push   $0x0
  pushl $193
c0102ddd:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102de2:	e9 e8 02 00 00       	jmp    c01030cf <__alltraps>

c0102de7 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102de7:	6a 00                	push   $0x0
  pushl $194
c0102de9:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102dee:	e9 dc 02 00 00       	jmp    c01030cf <__alltraps>

c0102df3 <vector195>:
.globl vector195
vector195:
  pushl $0
c0102df3:	6a 00                	push   $0x0
  pushl $195
c0102df5:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102dfa:	e9 d0 02 00 00       	jmp    c01030cf <__alltraps>

c0102dff <vector196>:
.globl vector196
vector196:
  pushl $0
c0102dff:	6a 00                	push   $0x0
  pushl $196
c0102e01:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102e06:	e9 c4 02 00 00       	jmp    c01030cf <__alltraps>

c0102e0b <vector197>:
.globl vector197
vector197:
  pushl $0
c0102e0b:	6a 00                	push   $0x0
  pushl $197
c0102e0d:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102e12:	e9 b8 02 00 00       	jmp    c01030cf <__alltraps>

c0102e17 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102e17:	6a 00                	push   $0x0
  pushl $198
c0102e19:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102e1e:	e9 ac 02 00 00       	jmp    c01030cf <__alltraps>

c0102e23 <vector199>:
.globl vector199
vector199:
  pushl $0
c0102e23:	6a 00                	push   $0x0
  pushl $199
c0102e25:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102e2a:	e9 a0 02 00 00       	jmp    c01030cf <__alltraps>

c0102e2f <vector200>:
.globl vector200
vector200:
  pushl $0
c0102e2f:	6a 00                	push   $0x0
  pushl $200
c0102e31:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102e36:	e9 94 02 00 00       	jmp    c01030cf <__alltraps>

c0102e3b <vector201>:
.globl vector201
vector201:
  pushl $0
c0102e3b:	6a 00                	push   $0x0
  pushl $201
c0102e3d:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102e42:	e9 88 02 00 00       	jmp    c01030cf <__alltraps>

c0102e47 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102e47:	6a 00                	push   $0x0
  pushl $202
c0102e49:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102e4e:	e9 7c 02 00 00       	jmp    c01030cf <__alltraps>

c0102e53 <vector203>:
.globl vector203
vector203:
  pushl $0
c0102e53:	6a 00                	push   $0x0
  pushl $203
c0102e55:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102e5a:	e9 70 02 00 00       	jmp    c01030cf <__alltraps>

c0102e5f <vector204>:
.globl vector204
vector204:
  pushl $0
c0102e5f:	6a 00                	push   $0x0
  pushl $204
c0102e61:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0102e66:	e9 64 02 00 00       	jmp    c01030cf <__alltraps>

c0102e6b <vector205>:
.globl vector205
vector205:
  pushl $0
c0102e6b:	6a 00                	push   $0x0
  pushl $205
c0102e6d:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102e72:	e9 58 02 00 00       	jmp    c01030cf <__alltraps>

c0102e77 <vector206>:
.globl vector206
vector206:
  pushl $0
c0102e77:	6a 00                	push   $0x0
  pushl $206
c0102e79:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102e7e:	e9 4c 02 00 00       	jmp    c01030cf <__alltraps>

c0102e83 <vector207>:
.globl vector207
vector207:
  pushl $0
c0102e83:	6a 00                	push   $0x0
  pushl $207
c0102e85:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102e8a:	e9 40 02 00 00       	jmp    c01030cf <__alltraps>

c0102e8f <vector208>:
.globl vector208
vector208:
  pushl $0
c0102e8f:	6a 00                	push   $0x0
  pushl $208
c0102e91:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102e96:	e9 34 02 00 00       	jmp    c01030cf <__alltraps>

c0102e9b <vector209>:
.globl vector209
vector209:
  pushl $0
c0102e9b:	6a 00                	push   $0x0
  pushl $209
c0102e9d:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102ea2:	e9 28 02 00 00       	jmp    c01030cf <__alltraps>

c0102ea7 <vector210>:
.globl vector210
vector210:
  pushl $0
c0102ea7:	6a 00                	push   $0x0
  pushl $210
c0102ea9:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102eae:	e9 1c 02 00 00       	jmp    c01030cf <__alltraps>

c0102eb3 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102eb3:	6a 00                	push   $0x0
  pushl $211
c0102eb5:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0102eba:	e9 10 02 00 00       	jmp    c01030cf <__alltraps>

c0102ebf <vector212>:
.globl vector212
vector212:
  pushl $0
c0102ebf:	6a 00                	push   $0x0
  pushl $212
c0102ec1:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102ec6:	e9 04 02 00 00       	jmp    c01030cf <__alltraps>

c0102ecb <vector213>:
.globl vector213
vector213:
  pushl $0
c0102ecb:	6a 00                	push   $0x0
  pushl $213
c0102ecd:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102ed2:	e9 f8 01 00 00       	jmp    c01030cf <__alltraps>

c0102ed7 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102ed7:	6a 00                	push   $0x0
  pushl $214
c0102ed9:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102ede:	e9 ec 01 00 00       	jmp    c01030cf <__alltraps>

c0102ee3 <vector215>:
.globl vector215
vector215:
  pushl $0
c0102ee3:	6a 00                	push   $0x0
  pushl $215
c0102ee5:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102eea:	e9 e0 01 00 00       	jmp    c01030cf <__alltraps>

c0102eef <vector216>:
.globl vector216
vector216:
  pushl $0
c0102eef:	6a 00                	push   $0x0
  pushl $216
c0102ef1:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102ef6:	e9 d4 01 00 00       	jmp    c01030cf <__alltraps>

c0102efb <vector217>:
.globl vector217
vector217:
  pushl $0
c0102efb:	6a 00                	push   $0x0
  pushl $217
c0102efd:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102f02:	e9 c8 01 00 00       	jmp    c01030cf <__alltraps>

c0102f07 <vector218>:
.globl vector218
vector218:
  pushl $0
c0102f07:	6a 00                	push   $0x0
  pushl $218
c0102f09:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102f0e:	e9 bc 01 00 00       	jmp    c01030cf <__alltraps>

c0102f13 <vector219>:
.globl vector219
vector219:
  pushl $0
c0102f13:	6a 00                	push   $0x0
  pushl $219
c0102f15:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102f1a:	e9 b0 01 00 00       	jmp    c01030cf <__alltraps>

c0102f1f <vector220>:
.globl vector220
vector220:
  pushl $0
c0102f1f:	6a 00                	push   $0x0
  pushl $220
c0102f21:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0102f26:	e9 a4 01 00 00       	jmp    c01030cf <__alltraps>

c0102f2b <vector221>:
.globl vector221
vector221:
  pushl $0
c0102f2b:	6a 00                	push   $0x0
  pushl $221
c0102f2d:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0102f32:	e9 98 01 00 00       	jmp    c01030cf <__alltraps>

c0102f37 <vector222>:
.globl vector222
vector222:
  pushl $0
c0102f37:	6a 00                	push   $0x0
  pushl $222
c0102f39:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102f3e:	e9 8c 01 00 00       	jmp    c01030cf <__alltraps>

c0102f43 <vector223>:
.globl vector223
vector223:
  pushl $0
c0102f43:	6a 00                	push   $0x0
  pushl $223
c0102f45:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0102f4a:	e9 80 01 00 00       	jmp    c01030cf <__alltraps>

c0102f4f <vector224>:
.globl vector224
vector224:
  pushl $0
c0102f4f:	6a 00                	push   $0x0
  pushl $224
c0102f51:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0102f56:	e9 74 01 00 00       	jmp    c01030cf <__alltraps>

c0102f5b <vector225>:
.globl vector225
vector225:
  pushl $0
c0102f5b:	6a 00                	push   $0x0
  pushl $225
c0102f5d:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0102f62:	e9 68 01 00 00       	jmp    c01030cf <__alltraps>

c0102f67 <vector226>:
.globl vector226
vector226:
  pushl $0
c0102f67:	6a 00                	push   $0x0
  pushl $226
c0102f69:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0102f6e:	e9 5c 01 00 00       	jmp    c01030cf <__alltraps>

c0102f73 <vector227>:
.globl vector227
vector227:
  pushl $0
c0102f73:	6a 00                	push   $0x0
  pushl $227
c0102f75:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0102f7a:	e9 50 01 00 00       	jmp    c01030cf <__alltraps>

c0102f7f <vector228>:
.globl vector228
vector228:
  pushl $0
c0102f7f:	6a 00                	push   $0x0
  pushl $228
c0102f81:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0102f86:	e9 44 01 00 00       	jmp    c01030cf <__alltraps>

c0102f8b <vector229>:
.globl vector229
vector229:
  pushl $0
c0102f8b:	6a 00                	push   $0x0
  pushl $229
c0102f8d:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0102f92:	e9 38 01 00 00       	jmp    c01030cf <__alltraps>

c0102f97 <vector230>:
.globl vector230
vector230:
  pushl $0
c0102f97:	6a 00                	push   $0x0
  pushl $230
c0102f99:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0102f9e:	e9 2c 01 00 00       	jmp    c01030cf <__alltraps>

c0102fa3 <vector231>:
.globl vector231
vector231:
  pushl $0
c0102fa3:	6a 00                	push   $0x0
  pushl $231
c0102fa5:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0102faa:	e9 20 01 00 00       	jmp    c01030cf <__alltraps>

c0102faf <vector232>:
.globl vector232
vector232:
  pushl $0
c0102faf:	6a 00                	push   $0x0
  pushl $232
c0102fb1:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0102fb6:	e9 14 01 00 00       	jmp    c01030cf <__alltraps>

c0102fbb <vector233>:
.globl vector233
vector233:
  pushl $0
c0102fbb:	6a 00                	push   $0x0
  pushl $233
c0102fbd:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102fc2:	e9 08 01 00 00       	jmp    c01030cf <__alltraps>

c0102fc7 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102fc7:	6a 00                	push   $0x0
  pushl $234
c0102fc9:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0102fce:	e9 fc 00 00 00       	jmp    c01030cf <__alltraps>

c0102fd3 <vector235>:
.globl vector235
vector235:
  pushl $0
c0102fd3:	6a 00                	push   $0x0
  pushl $235
c0102fd5:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0102fda:	e9 f0 00 00 00       	jmp    c01030cf <__alltraps>

c0102fdf <vector236>:
.globl vector236
vector236:
  pushl $0
c0102fdf:	6a 00                	push   $0x0
  pushl $236
c0102fe1:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0102fe6:	e9 e4 00 00 00       	jmp    c01030cf <__alltraps>

c0102feb <vector237>:
.globl vector237
vector237:
  pushl $0
c0102feb:	6a 00                	push   $0x0
  pushl $237
c0102fed:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0102ff2:	e9 d8 00 00 00       	jmp    c01030cf <__alltraps>

c0102ff7 <vector238>:
.globl vector238
vector238:
  pushl $0
c0102ff7:	6a 00                	push   $0x0
  pushl $238
c0102ff9:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0102ffe:	e9 cc 00 00 00       	jmp    c01030cf <__alltraps>

c0103003 <vector239>:
.globl vector239
vector239:
  pushl $0
c0103003:	6a 00                	push   $0x0
  pushl $239
c0103005:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c010300a:	e9 c0 00 00 00       	jmp    c01030cf <__alltraps>

c010300f <vector240>:
.globl vector240
vector240:
  pushl $0
c010300f:	6a 00                	push   $0x0
  pushl $240
c0103011:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0103016:	e9 b4 00 00 00       	jmp    c01030cf <__alltraps>

c010301b <vector241>:
.globl vector241
vector241:
  pushl $0
c010301b:	6a 00                	push   $0x0
  pushl $241
c010301d:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0103022:	e9 a8 00 00 00       	jmp    c01030cf <__alltraps>

c0103027 <vector242>:
.globl vector242
vector242:
  pushl $0
c0103027:	6a 00                	push   $0x0
  pushl $242
c0103029:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c010302e:	e9 9c 00 00 00       	jmp    c01030cf <__alltraps>

c0103033 <vector243>:
.globl vector243
vector243:
  pushl $0
c0103033:	6a 00                	push   $0x0
  pushl $243
c0103035:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c010303a:	e9 90 00 00 00       	jmp    c01030cf <__alltraps>

c010303f <vector244>:
.globl vector244
vector244:
  pushl $0
c010303f:	6a 00                	push   $0x0
  pushl $244
c0103041:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0103046:	e9 84 00 00 00       	jmp    c01030cf <__alltraps>

c010304b <vector245>:
.globl vector245
vector245:
  pushl $0
c010304b:	6a 00                	push   $0x0
  pushl $245
c010304d:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0103052:	e9 78 00 00 00       	jmp    c01030cf <__alltraps>

c0103057 <vector246>:
.globl vector246
vector246:
  pushl $0
c0103057:	6a 00                	push   $0x0
  pushl $246
c0103059:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c010305e:	e9 6c 00 00 00       	jmp    c01030cf <__alltraps>

c0103063 <vector247>:
.globl vector247
vector247:
  pushl $0
c0103063:	6a 00                	push   $0x0
  pushl $247
c0103065:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c010306a:	e9 60 00 00 00       	jmp    c01030cf <__alltraps>

c010306f <vector248>:
.globl vector248
vector248:
  pushl $0
c010306f:	6a 00                	push   $0x0
  pushl $248
c0103071:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0103076:	e9 54 00 00 00       	jmp    c01030cf <__alltraps>

c010307b <vector249>:
.globl vector249
vector249:
  pushl $0
c010307b:	6a 00                	push   $0x0
  pushl $249
c010307d:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0103082:	e9 48 00 00 00       	jmp    c01030cf <__alltraps>

c0103087 <vector250>:
.globl vector250
vector250:
  pushl $0
c0103087:	6a 00                	push   $0x0
  pushl $250
c0103089:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c010308e:	e9 3c 00 00 00       	jmp    c01030cf <__alltraps>

c0103093 <vector251>:
.globl vector251
vector251:
  pushl $0
c0103093:	6a 00                	push   $0x0
  pushl $251
c0103095:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c010309a:	e9 30 00 00 00       	jmp    c01030cf <__alltraps>

c010309f <vector252>:
.globl vector252
vector252:
  pushl $0
c010309f:	6a 00                	push   $0x0
  pushl $252
c01030a1:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01030a6:	e9 24 00 00 00       	jmp    c01030cf <__alltraps>

c01030ab <vector253>:
.globl vector253
vector253:
  pushl $0
c01030ab:	6a 00                	push   $0x0
  pushl $253
c01030ad:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01030b2:	e9 18 00 00 00       	jmp    c01030cf <__alltraps>

c01030b7 <vector254>:
.globl vector254
vector254:
  pushl $0
c01030b7:	6a 00                	push   $0x0
  pushl $254
c01030b9:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01030be:	e9 0c 00 00 00       	jmp    c01030cf <__alltraps>

c01030c3 <vector255>:
.globl vector255
vector255:
  pushl $0
c01030c3:	6a 00                	push   $0x0
  pushl $255
c01030c5:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01030ca:	e9 00 00 00 00       	jmp    c01030cf <__alltraps>

c01030cf <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c01030cf:	1e                   	push   %ds
    pushl %es
c01030d0:	06                   	push   %es
    pushl %fs
c01030d1:	0f a0                	push   %fs
    pushl %gs
c01030d3:	0f a8                	push   %gs
    pushal
c01030d5:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c01030d6:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c01030db:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c01030dd:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c01030df:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c01030e0:	e8 63 f5 ff ff       	call   c0102648 <trap>

    # pop the pushed stack pointer
    popl %esp
c01030e5:	5c                   	pop    %esp

c01030e6 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c01030e6:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c01030e7:	0f a9                	pop    %gs
    popl %fs
c01030e9:	0f a1                	pop    %fs
    popl %es
c01030eb:	07                   	pop    %es
    popl %ds
c01030ec:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c01030ed:	83 c4 08             	add    $0x8,%esp
    iret
c01030f0:	cf                   	iret   

c01030f1 <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c01030f1:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c01030f5:	eb ef                	jmp    c01030e6 <__trapret>

c01030f7 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c01030f7:	55                   	push   %ebp
c01030f8:	89 e5                	mov    %esp,%ebp
c01030fa:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c01030fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0103100:	c1 e8 0c             	shr    $0xc,%eax
c0103103:	89 c2                	mov    %eax,%edx
c0103105:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c010310a:	39 c2                	cmp    %eax,%edx
c010310c:	72 14                	jb     c0103122 <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c010310e:	83 ec 04             	sub    $0x4,%esp
c0103111:	68 10 9d 10 c0       	push   $0xc0109d10
c0103116:	6a 5f                	push   $0x5f
c0103118:	68 2f 9d 10 c0       	push   $0xc0109d2f
c010311d:	e8 ce d2 ff ff       	call   c01003f0 <__panic>
    }
    return &pages[PPN(pa)];
c0103122:	8b 0d 58 a1 12 c0    	mov    0xc012a158,%ecx
c0103128:	8b 45 08             	mov    0x8(%ebp),%eax
c010312b:	c1 e8 0c             	shr    $0xc,%eax
c010312e:	89 c2                	mov    %eax,%edx
c0103130:	89 d0                	mov    %edx,%eax
c0103132:	c1 e0 03             	shl    $0x3,%eax
c0103135:	01 d0                	add    %edx,%eax
c0103137:	c1 e0 02             	shl    $0x2,%eax
c010313a:	01 c8                	add    %ecx,%eax
}
c010313c:	c9                   	leave  
c010313d:	c3                   	ret    

c010313e <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c010313e:	55                   	push   %ebp
c010313f:	89 e5                	mov    %esp,%ebp
c0103141:	83 ec 08             	sub    $0x8,%esp
    return pa2page(PDE_ADDR(pde));
c0103144:	8b 45 08             	mov    0x8(%ebp),%eax
c0103147:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010314c:	83 ec 0c             	sub    $0xc,%esp
c010314f:	50                   	push   %eax
c0103150:	e8 a2 ff ff ff       	call   c01030f7 <pa2page>
c0103155:	83 c4 10             	add    $0x10,%esp
}
c0103158:	c9                   	leave  
c0103159:	c3                   	ret    

c010315a <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c010315a:	55                   	push   %ebp
c010315b:	89 e5                	mov    %esp,%ebp
c010315d:	83 ec 18             	sub    $0x18,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0103160:	83 ec 0c             	sub    $0xc,%esp
c0103163:	6a 18                	push   $0x18
c0103165:	e8 3e 16 00 00       	call   c01047a8 <kmalloc>
c010316a:	83 c4 10             	add    $0x10,%esp
c010316d:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0103170:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103174:	74 5b                	je     c01031d1 <mm_create+0x77>
        list_init(&(mm->mmap_list));
c0103176:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103179:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010317c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010317f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103182:	89 50 04             	mov    %edx,0x4(%eax)
c0103185:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103188:	8b 50 04             	mov    0x4(%eax),%edx
c010318b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010318e:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c0103190:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103193:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c010319a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010319d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c01031a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031a7:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c01031ae:	a1 6c 7f 12 c0       	mov    0xc0127f6c,%eax
c01031b3:	85 c0                	test   %eax,%eax
c01031b5:	74 10                	je     c01031c7 <mm_create+0x6d>
c01031b7:	83 ec 0c             	sub    $0xc,%esp
c01031ba:	ff 75 f4             	pushl  -0xc(%ebp)
c01031bd:	e8 50 18 00 00       	call   c0104a12 <swap_init_mm>
c01031c2:	83 c4 10             	add    $0x10,%esp
c01031c5:	eb 0a                	jmp    c01031d1 <mm_create+0x77>
        else mm->sm_priv = NULL;
c01031c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031ca:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c01031d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01031d4:	c9                   	leave  
c01031d5:	c3                   	ret    

c01031d6 <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c01031d6:	55                   	push   %ebp
c01031d7:	89 e5                	mov    %esp,%ebp
c01031d9:	83 ec 18             	sub    $0x18,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c01031dc:	83 ec 0c             	sub    $0xc,%esp
c01031df:	6a 18                	push   $0x18
c01031e1:	e8 c2 15 00 00       	call   c01047a8 <kmalloc>
c01031e6:	83 c4 10             	add    $0x10,%esp
c01031e9:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c01031ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01031f0:	74 1b                	je     c010320d <vma_create+0x37>
        vma->vm_start = vm_start;
c01031f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031f5:	8b 55 08             	mov    0x8(%ebp),%edx
c01031f8:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c01031fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031fe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103201:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0103204:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103207:	8b 55 10             	mov    0x10(%ebp),%edx
c010320a:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c010320d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103210:	c9                   	leave  
c0103211:	c3                   	ret    

c0103212 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c0103212:	55                   	push   %ebp
c0103213:	89 e5                	mov    %esp,%ebp
c0103215:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0103218:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c010321f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103223:	0f 84 95 00 00 00    	je     c01032be <find_vma+0xac>
        vma = mm->mmap_cache;
c0103229:	8b 45 08             	mov    0x8(%ebp),%eax
c010322c:	8b 40 08             	mov    0x8(%eax),%eax
c010322f:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0103232:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0103236:	74 16                	je     c010324e <find_vma+0x3c>
c0103238:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010323b:	8b 40 04             	mov    0x4(%eax),%eax
c010323e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103241:	77 0b                	ja     c010324e <find_vma+0x3c>
c0103243:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103246:	8b 40 08             	mov    0x8(%eax),%eax
c0103249:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010324c:	77 61                	ja     c01032af <find_vma+0x9d>
                bool found = 0;
c010324e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c0103255:	8b 45 08             	mov    0x8(%ebp),%eax
c0103258:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010325b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010325e:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c0103261:	eb 28                	jmp    c010328b <find_vma+0x79>
                    vma = le2vma(le, list_link);
c0103263:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103266:	83 e8 10             	sub    $0x10,%eax
c0103269:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c010326c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010326f:	8b 40 04             	mov    0x4(%eax),%eax
c0103272:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103275:	77 14                	ja     c010328b <find_vma+0x79>
c0103277:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010327a:	8b 40 08             	mov    0x8(%eax),%eax
c010327d:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103280:	76 09                	jbe    c010328b <find_vma+0x79>
                        found = 1;
c0103282:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c0103289:	eb 17                	jmp    c01032a2 <find_vma+0x90>
c010328b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010328e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103291:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103294:	8b 40 04             	mov    0x4(%eax),%eax
    if (mm != NULL) {
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
c0103297:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010329a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010329d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01032a0:	75 c1                	jne    c0103263 <find_vma+0x51>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
c01032a2:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c01032a6:	75 07                	jne    c01032af <find_vma+0x9d>
                    vma = NULL;
c01032a8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c01032af:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01032b3:	74 09                	je     c01032be <find_vma+0xac>
            mm->mmap_cache = vma;
c01032b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01032b8:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01032bb:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c01032be:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01032c1:	c9                   	leave  
c01032c2:	c3                   	ret    

c01032c3 <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c01032c3:	55                   	push   %ebp
c01032c4:	89 e5                	mov    %esp,%ebp
c01032c6:	83 ec 08             	sub    $0x8,%esp
    assert(prev->vm_start < prev->vm_end);
c01032c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01032cc:	8b 50 04             	mov    0x4(%eax),%edx
c01032cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01032d2:	8b 40 08             	mov    0x8(%eax),%eax
c01032d5:	39 c2                	cmp    %eax,%edx
c01032d7:	72 16                	jb     c01032ef <check_vma_overlap+0x2c>
c01032d9:	68 3d 9d 10 c0       	push   $0xc0109d3d
c01032de:	68 5b 9d 10 c0       	push   $0xc0109d5b
c01032e3:	6a 68                	push   $0x68
c01032e5:	68 70 9d 10 c0       	push   $0xc0109d70
c01032ea:	e8 01 d1 ff ff       	call   c01003f0 <__panic>
    assert(prev->vm_end <= next->vm_start);
c01032ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01032f2:	8b 50 08             	mov    0x8(%eax),%edx
c01032f5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01032f8:	8b 40 04             	mov    0x4(%eax),%eax
c01032fb:	39 c2                	cmp    %eax,%edx
c01032fd:	76 16                	jbe    c0103315 <check_vma_overlap+0x52>
c01032ff:	68 80 9d 10 c0       	push   $0xc0109d80
c0103304:	68 5b 9d 10 c0       	push   $0xc0109d5b
c0103309:	6a 69                	push   $0x69
c010330b:	68 70 9d 10 c0       	push   $0xc0109d70
c0103310:	e8 db d0 ff ff       	call   c01003f0 <__panic>
    assert(next->vm_start < next->vm_end);
c0103315:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103318:	8b 50 04             	mov    0x4(%eax),%edx
c010331b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010331e:	8b 40 08             	mov    0x8(%eax),%eax
c0103321:	39 c2                	cmp    %eax,%edx
c0103323:	72 16                	jb     c010333b <check_vma_overlap+0x78>
c0103325:	68 9f 9d 10 c0       	push   $0xc0109d9f
c010332a:	68 5b 9d 10 c0       	push   $0xc0109d5b
c010332f:	6a 6a                	push   $0x6a
c0103331:	68 70 9d 10 c0       	push   $0xc0109d70
c0103336:	e8 b5 d0 ff ff       	call   c01003f0 <__panic>
}
c010333b:	90                   	nop
c010333c:	c9                   	leave  
c010333d:	c3                   	ret    

c010333e <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c010333e:	55                   	push   %ebp
c010333f:	89 e5                	mov    %esp,%ebp
c0103341:	83 ec 38             	sub    $0x38,%esp
    assert(vma->vm_start < vma->vm_end);
c0103344:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103347:	8b 50 04             	mov    0x4(%eax),%edx
c010334a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010334d:	8b 40 08             	mov    0x8(%eax),%eax
c0103350:	39 c2                	cmp    %eax,%edx
c0103352:	72 16                	jb     c010336a <insert_vma_struct+0x2c>
c0103354:	68 bd 9d 10 c0       	push   $0xc0109dbd
c0103359:	68 5b 9d 10 c0       	push   $0xc0109d5b
c010335e:	6a 71                	push   $0x71
c0103360:	68 70 9d 10 c0       	push   $0xc0109d70
c0103365:	e8 86 d0 ff ff       	call   c01003f0 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c010336a:	8b 45 08             	mov    0x8(%ebp),%eax
c010336d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c0103370:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103373:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c0103376:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103379:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c010337c:	eb 1f                	jmp    c010339d <insert_vma_struct+0x5f>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c010337e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103381:	83 e8 10             	sub    $0x10,%eax
c0103384:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c0103387:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010338a:	8b 50 04             	mov    0x4(%eax),%edx
c010338d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103390:	8b 40 04             	mov    0x4(%eax),%eax
c0103393:	39 c2                	cmp    %eax,%edx
c0103395:	77 1f                	ja     c01033b6 <insert_vma_struct+0x78>
                break;
            }
            le_prev = le;
c0103397:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010339a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010339d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01033a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01033a3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01033a6:	8b 40 04             	mov    0x4(%eax),%eax
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
c01033a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01033ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01033af:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01033b2:	75 ca                	jne    c010337e <insert_vma_struct+0x40>
c01033b4:	eb 01                	jmp    c01033b7 <insert_vma_struct+0x79>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
                break;
c01033b6:	90                   	nop
c01033b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033ba:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01033bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01033c0:	8b 40 04             	mov    0x4(%eax),%eax
            }
            le_prev = le;
        }

    le_next = list_next(le_prev);
c01033c3:	89 45 dc             	mov    %eax,-0x24(%ebp)

    /* check overlap */
    if (le_prev != list) {
c01033c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033c9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01033cc:	74 15                	je     c01033e3 <insert_vma_struct+0xa5>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c01033ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033d1:	83 e8 10             	sub    $0x10,%eax
c01033d4:	83 ec 08             	sub    $0x8,%esp
c01033d7:	ff 75 0c             	pushl  0xc(%ebp)
c01033da:	50                   	push   %eax
c01033db:	e8 e3 fe ff ff       	call   c01032c3 <check_vma_overlap>
c01033e0:	83 c4 10             	add    $0x10,%esp
    }
    if (le_next != list) {
c01033e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01033e6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01033e9:	74 15                	je     c0103400 <insert_vma_struct+0xc2>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c01033eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01033ee:	83 e8 10             	sub    $0x10,%eax
c01033f1:	83 ec 08             	sub    $0x8,%esp
c01033f4:	50                   	push   %eax
c01033f5:	ff 75 0c             	pushl  0xc(%ebp)
c01033f8:	e8 c6 fe ff ff       	call   c01032c3 <check_vma_overlap>
c01033fd:	83 c4 10             	add    $0x10,%esp
    }

    vma->vm_mm = mm;
c0103400:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103403:	8b 55 08             	mov    0x8(%ebp),%edx
c0103406:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c0103408:	8b 45 0c             	mov    0xc(%ebp),%eax
c010340b:	8d 50 10             	lea    0x10(%eax),%edx
c010340e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103411:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103414:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0103417:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010341a:	8b 40 04             	mov    0x4(%eax),%eax
c010341d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103420:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0103423:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103426:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0103429:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010342c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010342f:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103432:	89 10                	mov    %edx,(%eax)
c0103434:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103437:	8b 10                	mov    (%eax),%edx
c0103439:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010343c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010343f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103442:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0103445:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103448:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010344b:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010344e:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c0103450:	8b 45 08             	mov    0x8(%ebp),%eax
c0103453:	8b 40 10             	mov    0x10(%eax),%eax
c0103456:	8d 50 01             	lea    0x1(%eax),%edx
c0103459:	8b 45 08             	mov    0x8(%ebp),%eax
c010345c:	89 50 10             	mov    %edx,0x10(%eax)
}
c010345f:	90                   	nop
c0103460:	c9                   	leave  
c0103461:	c3                   	ret    

c0103462 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c0103462:	55                   	push   %ebp
c0103463:	89 e5                	mov    %esp,%ebp
c0103465:	83 ec 28             	sub    $0x28,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c0103468:	8b 45 08             	mov    0x8(%ebp),%eax
c010346b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c010346e:	eb 3a                	jmp    c01034aa <mm_destroy+0x48>
c0103470:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103473:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103476:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103479:	8b 40 04             	mov    0x4(%eax),%eax
c010347c:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010347f:	8b 12                	mov    (%edx),%edx
c0103481:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0103484:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103487:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010348a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010348d:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103490:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103493:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103496:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
c0103498:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010349b:	83 e8 10             	sub    $0x10,%eax
c010349e:	83 ec 0c             	sub    $0xc,%esp
c01034a1:	50                   	push   %eax
c01034a2:	e8 19 13 00 00       	call   c01047c0 <kfree>
c01034a7:	83 c4 10             	add    $0x10,%esp
c01034aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01034b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01034b3:	8b 40 04             	mov    0x4(%eax),%eax
// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
c01034b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01034b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01034bc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01034bf:	75 af                	jne    c0103470 <mm_destroy+0xe>
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
    }
    kfree(mm); //kfree mm
c01034c1:	83 ec 0c             	sub    $0xc,%esp
c01034c4:	ff 75 08             	pushl  0x8(%ebp)
c01034c7:	e8 f4 12 00 00       	call   c01047c0 <kfree>
c01034cc:	83 c4 10             	add    $0x10,%esp
    mm=NULL;
c01034cf:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c01034d6:	90                   	nop
c01034d7:	c9                   	leave  
c01034d8:	c3                   	ret    

c01034d9 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c01034d9:	55                   	push   %ebp
c01034da:	89 e5                	mov    %esp,%ebp
c01034dc:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c01034df:	e8 03 00 00 00       	call   c01034e7 <check_vmm>
}
c01034e4:	90                   	nop
c01034e5:	c9                   	leave  
c01034e6:	c3                   	ret    

c01034e7 <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c01034e7:	55                   	push   %ebp
c01034e8:	89 e5                	mov    %esp,%ebp
c01034ea:	83 ec 18             	sub    $0x18,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01034ed:	e8 8d 32 00 00       	call   c010677f <nr_free_pages>
c01034f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c01034f5:	e8 18 00 00 00       	call   c0103512 <check_vma_struct>
    check_pgfault();
c01034fa:	e8 10 04 00 00       	call   c010390f <check_pgfault>

 //   assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_vmm() succeeded.\n");
c01034ff:	83 ec 0c             	sub    $0xc,%esp
c0103502:	68 d9 9d 10 c0       	push   $0xc0109dd9
c0103507:	e8 7e cd ff ff       	call   c010028a <cprintf>
c010350c:	83 c4 10             	add    $0x10,%esp
}
c010350f:	90                   	nop
c0103510:	c9                   	leave  
c0103511:	c3                   	ret    

c0103512 <check_vma_struct>:

static void
check_vma_struct(void) {
c0103512:	55                   	push   %ebp
c0103513:	89 e5                	mov    %esp,%ebp
c0103515:	83 ec 58             	sub    $0x58,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0103518:	e8 62 32 00 00       	call   c010677f <nr_free_pages>
c010351d:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0103520:	e8 35 fc ff ff       	call   c010315a <mm_create>
c0103525:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0103528:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010352c:	75 19                	jne    c0103547 <check_vma_struct+0x35>
c010352e:	68 f1 9d 10 c0       	push   $0xc0109df1
c0103533:	68 5b 9d 10 c0       	push   $0xc0109d5b
c0103538:	68 b4 00 00 00       	push   $0xb4
c010353d:	68 70 9d 10 c0       	push   $0xc0109d70
c0103542:	e8 a9 ce ff ff       	call   c01003f0 <__panic>

    int step1 = 10, step2 = step1 * 10;
c0103547:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c010354e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103551:	89 d0                	mov    %edx,%eax
c0103553:	c1 e0 02             	shl    $0x2,%eax
c0103556:	01 d0                	add    %edx,%eax
c0103558:	01 c0                	add    %eax,%eax
c010355a:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c010355d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103560:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103563:	eb 5f                	jmp    c01035c4 <check_vma_struct+0xb2>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0103565:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103568:	89 d0                	mov    %edx,%eax
c010356a:	c1 e0 02             	shl    $0x2,%eax
c010356d:	01 d0                	add    %edx,%eax
c010356f:	83 c0 02             	add    $0x2,%eax
c0103572:	89 c1                	mov    %eax,%ecx
c0103574:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103577:	89 d0                	mov    %edx,%eax
c0103579:	c1 e0 02             	shl    $0x2,%eax
c010357c:	01 d0                	add    %edx,%eax
c010357e:	83 ec 04             	sub    $0x4,%esp
c0103581:	6a 00                	push   $0x0
c0103583:	51                   	push   %ecx
c0103584:	50                   	push   %eax
c0103585:	e8 4c fc ff ff       	call   c01031d6 <vma_create>
c010358a:	83 c4 10             	add    $0x10,%esp
c010358d:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(vma != NULL);
c0103590:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103594:	75 19                	jne    c01035af <check_vma_struct+0x9d>
c0103596:	68 fc 9d 10 c0       	push   $0xc0109dfc
c010359b:	68 5b 9d 10 c0       	push   $0xc0109d5b
c01035a0:	68 bb 00 00 00       	push   $0xbb
c01035a5:	68 70 9d 10 c0       	push   $0xc0109d70
c01035aa:	e8 41 ce ff ff       	call   c01003f0 <__panic>
        insert_vma_struct(mm, vma);
c01035af:	83 ec 08             	sub    $0x8,%esp
c01035b2:	ff 75 dc             	pushl  -0x24(%ebp)
c01035b5:	ff 75 e8             	pushl  -0x18(%ebp)
c01035b8:	e8 81 fd ff ff       	call   c010333e <insert_vma_struct>
c01035bd:	83 c4 10             	add    $0x10,%esp
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
c01035c0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01035c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01035c8:	7f 9b                	jg     c0103565 <check_vma_struct+0x53>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c01035ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01035cd:	83 c0 01             	add    $0x1,%eax
c01035d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01035d3:	eb 5f                	jmp    c0103634 <check_vma_struct+0x122>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c01035d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01035d8:	89 d0                	mov    %edx,%eax
c01035da:	c1 e0 02             	shl    $0x2,%eax
c01035dd:	01 d0                	add    %edx,%eax
c01035df:	83 c0 02             	add    $0x2,%eax
c01035e2:	89 c1                	mov    %eax,%ecx
c01035e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01035e7:	89 d0                	mov    %edx,%eax
c01035e9:	c1 e0 02             	shl    $0x2,%eax
c01035ec:	01 d0                	add    %edx,%eax
c01035ee:	83 ec 04             	sub    $0x4,%esp
c01035f1:	6a 00                	push   $0x0
c01035f3:	51                   	push   %ecx
c01035f4:	50                   	push   %eax
c01035f5:	e8 dc fb ff ff       	call   c01031d6 <vma_create>
c01035fa:	83 c4 10             	add    $0x10,%esp
c01035fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma != NULL);
c0103600:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0103604:	75 19                	jne    c010361f <check_vma_struct+0x10d>
c0103606:	68 fc 9d 10 c0       	push   $0xc0109dfc
c010360b:	68 5b 9d 10 c0       	push   $0xc0109d5b
c0103610:	68 c1 00 00 00       	push   $0xc1
c0103615:	68 70 9d 10 c0       	push   $0xc0109d70
c010361a:	e8 d1 cd ff ff       	call   c01003f0 <__panic>
        insert_vma_struct(mm, vma);
c010361f:	83 ec 08             	sub    $0x8,%esp
c0103622:	ff 75 d8             	pushl  -0x28(%ebp)
c0103625:	ff 75 e8             	pushl  -0x18(%ebp)
c0103628:	e8 11 fd ff ff       	call   c010333e <insert_vma_struct>
c010362d:	83 c4 10             	add    $0x10,%esp
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0103630:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103634:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103637:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010363a:	7e 99                	jle    c01035d5 <check_vma_struct+0xc3>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c010363c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010363f:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0103642:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103645:	8b 40 04             	mov    0x4(%eax),%eax
c0103648:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c010364b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0103652:	e9 81 00 00 00       	jmp    c01036d8 <check_vma_struct+0x1c6>
        assert(le != &(mm->mmap_list));
c0103657:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010365a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010365d:	75 19                	jne    c0103678 <check_vma_struct+0x166>
c010365f:	68 08 9e 10 c0       	push   $0xc0109e08
c0103664:	68 5b 9d 10 c0       	push   $0xc0109d5b
c0103669:	68 c8 00 00 00       	push   $0xc8
c010366e:	68 70 9d 10 c0       	push   $0xc0109d70
c0103673:	e8 78 cd ff ff       	call   c01003f0 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0103678:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010367b:	83 e8 10             	sub    $0x10,%eax
c010367e:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0103681:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103684:	8b 48 04             	mov    0x4(%eax),%ecx
c0103687:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010368a:	89 d0                	mov    %edx,%eax
c010368c:	c1 e0 02             	shl    $0x2,%eax
c010368f:	01 d0                	add    %edx,%eax
c0103691:	39 c1                	cmp    %eax,%ecx
c0103693:	75 17                	jne    c01036ac <check_vma_struct+0x19a>
c0103695:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103698:	8b 48 08             	mov    0x8(%eax),%ecx
c010369b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010369e:	89 d0                	mov    %edx,%eax
c01036a0:	c1 e0 02             	shl    $0x2,%eax
c01036a3:	01 d0                	add    %edx,%eax
c01036a5:	83 c0 02             	add    $0x2,%eax
c01036a8:	39 c1                	cmp    %eax,%ecx
c01036aa:	74 19                	je     c01036c5 <check_vma_struct+0x1b3>
c01036ac:	68 20 9e 10 c0       	push   $0xc0109e20
c01036b1:	68 5b 9d 10 c0       	push   $0xc0109d5b
c01036b6:	68 ca 00 00 00       	push   $0xca
c01036bb:	68 70 9d 10 c0       	push   $0xc0109d70
c01036c0:	e8 2b cd ff ff       	call   c01003f0 <__panic>
c01036c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01036c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01036cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01036ce:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c01036d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
c01036d4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01036d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036db:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01036de:	0f 8e 73 ff ff ff    	jle    c0103657 <check_vma_struct+0x145>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c01036e4:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c01036eb:	e9 80 01 00 00       	jmp    c0103870 <check_vma_struct+0x35e>
        struct vma_struct *vma1 = find_vma(mm, i);
c01036f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036f3:	83 ec 08             	sub    $0x8,%esp
c01036f6:	50                   	push   %eax
c01036f7:	ff 75 e8             	pushl  -0x18(%ebp)
c01036fa:	e8 13 fb ff ff       	call   c0103212 <find_vma>
c01036ff:	83 c4 10             	add    $0x10,%esp
c0103702:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma1 != NULL);
c0103705:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0103709:	75 19                	jne    c0103724 <check_vma_struct+0x212>
c010370b:	68 55 9e 10 c0       	push   $0xc0109e55
c0103710:	68 5b 9d 10 c0       	push   $0xc0109d5b
c0103715:	68 d0 00 00 00       	push   $0xd0
c010371a:	68 70 9d 10 c0       	push   $0xc0109d70
c010371f:	e8 cc cc ff ff       	call   c01003f0 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0103724:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103727:	83 c0 01             	add    $0x1,%eax
c010372a:	83 ec 08             	sub    $0x8,%esp
c010372d:	50                   	push   %eax
c010372e:	ff 75 e8             	pushl  -0x18(%ebp)
c0103731:	e8 dc fa ff ff       	call   c0103212 <find_vma>
c0103736:	83 c4 10             	add    $0x10,%esp
c0103739:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma2 != NULL);
c010373c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0103740:	75 19                	jne    c010375b <check_vma_struct+0x249>
c0103742:	68 62 9e 10 c0       	push   $0xc0109e62
c0103747:	68 5b 9d 10 c0       	push   $0xc0109d5b
c010374c:	68 d2 00 00 00       	push   $0xd2
c0103751:	68 70 9d 10 c0       	push   $0xc0109d70
c0103756:	e8 95 cc ff ff       	call   c01003f0 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c010375b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010375e:	83 c0 02             	add    $0x2,%eax
c0103761:	83 ec 08             	sub    $0x8,%esp
c0103764:	50                   	push   %eax
c0103765:	ff 75 e8             	pushl  -0x18(%ebp)
c0103768:	e8 a5 fa ff ff       	call   c0103212 <find_vma>
c010376d:	83 c4 10             	add    $0x10,%esp
c0103770:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(vma3 == NULL);
c0103773:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c0103777:	74 19                	je     c0103792 <check_vma_struct+0x280>
c0103779:	68 6f 9e 10 c0       	push   $0xc0109e6f
c010377e:	68 5b 9d 10 c0       	push   $0xc0109d5b
c0103783:	68 d4 00 00 00       	push   $0xd4
c0103788:	68 70 9d 10 c0       	push   $0xc0109d70
c010378d:	e8 5e cc ff ff       	call   c01003f0 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0103792:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103795:	83 c0 03             	add    $0x3,%eax
c0103798:	83 ec 08             	sub    $0x8,%esp
c010379b:	50                   	push   %eax
c010379c:	ff 75 e8             	pushl  -0x18(%ebp)
c010379f:	e8 6e fa ff ff       	call   c0103212 <find_vma>
c01037a4:	83 c4 10             	add    $0x10,%esp
c01037a7:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma4 == NULL);
c01037aa:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c01037ae:	74 19                	je     c01037c9 <check_vma_struct+0x2b7>
c01037b0:	68 7c 9e 10 c0       	push   $0xc0109e7c
c01037b5:	68 5b 9d 10 c0       	push   $0xc0109d5b
c01037ba:	68 d6 00 00 00       	push   $0xd6
c01037bf:	68 70 9d 10 c0       	push   $0xc0109d70
c01037c4:	e8 27 cc ff ff       	call   c01003f0 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c01037c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037cc:	83 c0 04             	add    $0x4,%eax
c01037cf:	83 ec 08             	sub    $0x8,%esp
c01037d2:	50                   	push   %eax
c01037d3:	ff 75 e8             	pushl  -0x18(%ebp)
c01037d6:	e8 37 fa ff ff       	call   c0103212 <find_vma>
c01037db:	83 c4 10             	add    $0x10,%esp
c01037de:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma5 == NULL);
c01037e1:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01037e5:	74 19                	je     c0103800 <check_vma_struct+0x2ee>
c01037e7:	68 89 9e 10 c0       	push   $0xc0109e89
c01037ec:	68 5b 9d 10 c0       	push   $0xc0109d5b
c01037f1:	68 d8 00 00 00       	push   $0xd8
c01037f6:	68 70 9d 10 c0       	push   $0xc0109d70
c01037fb:	e8 f0 cb ff ff       	call   c01003f0 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0103800:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103803:	8b 50 04             	mov    0x4(%eax),%edx
c0103806:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103809:	39 c2                	cmp    %eax,%edx
c010380b:	75 10                	jne    c010381d <check_vma_struct+0x30b>
c010380d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103810:	8b 40 08             	mov    0x8(%eax),%eax
c0103813:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103816:	83 c2 02             	add    $0x2,%edx
c0103819:	39 d0                	cmp    %edx,%eax
c010381b:	74 19                	je     c0103836 <check_vma_struct+0x324>
c010381d:	68 98 9e 10 c0       	push   $0xc0109e98
c0103822:	68 5b 9d 10 c0       	push   $0xc0109d5b
c0103827:	68 da 00 00 00       	push   $0xda
c010382c:	68 70 9d 10 c0       	push   $0xc0109d70
c0103831:	e8 ba cb ff ff       	call   c01003f0 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0103836:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103839:	8b 50 04             	mov    0x4(%eax),%edx
c010383c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010383f:	39 c2                	cmp    %eax,%edx
c0103841:	75 10                	jne    c0103853 <check_vma_struct+0x341>
c0103843:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103846:	8b 40 08             	mov    0x8(%eax),%eax
c0103849:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010384c:	83 c2 02             	add    $0x2,%edx
c010384f:	39 d0                	cmp    %edx,%eax
c0103851:	74 19                	je     c010386c <check_vma_struct+0x35a>
c0103853:	68 c8 9e 10 c0       	push   $0xc0109ec8
c0103858:	68 5b 9d 10 c0       	push   $0xc0109d5b
c010385d:	68 db 00 00 00       	push   $0xdb
c0103862:	68 70 9d 10 c0       	push   $0xc0109d70
c0103867:	e8 84 cb ff ff       	call   c01003f0 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c010386c:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0103870:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103873:	89 d0                	mov    %edx,%eax
c0103875:	c1 e0 02             	shl    $0x2,%eax
c0103878:	01 d0                	add    %edx,%eax
c010387a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010387d:	0f 8d 6d fe ff ff    	jge    c01036f0 <check_vma_struct+0x1de>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0103883:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c010388a:	eb 5c                	jmp    c01038e8 <check_vma_struct+0x3d6>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c010388c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010388f:	83 ec 08             	sub    $0x8,%esp
c0103892:	50                   	push   %eax
c0103893:	ff 75 e8             	pushl  -0x18(%ebp)
c0103896:	e8 77 f9 ff ff       	call   c0103212 <find_vma>
c010389b:	83 c4 10             	add    $0x10,%esp
c010389e:	89 45 b8             	mov    %eax,-0x48(%ebp)
        if (vma_below_5 != NULL ) {
c01038a1:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01038a5:	74 1e                	je     c01038c5 <check_vma_struct+0x3b3>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c01038a7:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01038aa:	8b 50 08             	mov    0x8(%eax),%edx
c01038ad:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01038b0:	8b 40 04             	mov    0x4(%eax),%eax
c01038b3:	52                   	push   %edx
c01038b4:	50                   	push   %eax
c01038b5:	ff 75 f4             	pushl  -0xc(%ebp)
c01038b8:	68 f8 9e 10 c0       	push   $0xc0109ef8
c01038bd:	e8 c8 c9 ff ff       	call   c010028a <cprintf>
c01038c2:	83 c4 10             	add    $0x10,%esp
        }
        assert(vma_below_5 == NULL);
c01038c5:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01038c9:	74 19                	je     c01038e4 <check_vma_struct+0x3d2>
c01038cb:	68 1d 9f 10 c0       	push   $0xc0109f1d
c01038d0:	68 5b 9d 10 c0       	push   $0xc0109d5b
c01038d5:	68 e3 00 00 00       	push   $0xe3
c01038da:	68 70 9d 10 c0       	push   $0xc0109d70
c01038df:	e8 0c cb ff ff       	call   c01003f0 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c01038e4:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01038e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01038ec:	79 9e                	jns    c010388c <check_vma_struct+0x37a>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
c01038ee:	83 ec 0c             	sub    $0xc,%esp
c01038f1:	ff 75 e8             	pushl  -0x18(%ebp)
c01038f4:	e8 69 fb ff ff       	call   c0103462 <mm_destroy>
c01038f9:	83 c4 10             	add    $0x10,%esp

//    assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_vma_struct() succeeded!\n");
c01038fc:	83 ec 0c             	sub    $0xc,%esp
c01038ff:	68 34 9f 10 c0       	push   $0xc0109f34
c0103904:	e8 81 c9 ff ff       	call   c010028a <cprintf>
c0103909:	83 c4 10             	add    $0x10,%esp
}
c010390c:	90                   	nop
c010390d:	c9                   	leave  
c010390e:	c3                   	ret    

c010390f <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c010390f:	55                   	push   %ebp
c0103910:	89 e5                	mov    %esp,%ebp
c0103912:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0103915:	e8 65 2e 00 00       	call   c010677f <nr_free_pages>
c010391a:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c010391d:	e8 38 f8 ff ff       	call   c010315a <mm_create>
c0103922:	a3 58 a0 12 c0       	mov    %eax,0xc012a058
    assert(check_mm_struct != NULL);
c0103927:	a1 58 a0 12 c0       	mov    0xc012a058,%eax
c010392c:	85 c0                	test   %eax,%eax
c010392e:	75 19                	jne    c0103949 <check_pgfault+0x3a>
c0103930:	68 53 9f 10 c0       	push   $0xc0109f53
c0103935:	68 5b 9d 10 c0       	push   $0xc0109d5b
c010393a:	68 f5 00 00 00       	push   $0xf5
c010393f:	68 70 9d 10 c0       	push   $0xc0109d70
c0103944:	e8 a7 ca ff ff       	call   c01003f0 <__panic>

    struct mm_struct *mm = check_mm_struct;
c0103949:	a1 58 a0 12 c0       	mov    0xc012a058,%eax
c010394e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0103951:	8b 15 20 4a 12 c0    	mov    0xc0124a20,%edx
c0103957:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010395a:	89 50 0c             	mov    %edx,0xc(%eax)
c010395d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103960:	8b 40 0c             	mov    0xc(%eax),%eax
c0103963:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0103966:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103969:	8b 00                	mov    (%eax),%eax
c010396b:	85 c0                	test   %eax,%eax
c010396d:	74 19                	je     c0103988 <check_pgfault+0x79>
c010396f:	68 6b 9f 10 c0       	push   $0xc0109f6b
c0103974:	68 5b 9d 10 c0       	push   $0xc0109d5b
c0103979:	68 f9 00 00 00       	push   $0xf9
c010397e:	68 70 9d 10 c0       	push   $0xc0109d70
c0103983:	e8 68 ca ff ff       	call   c01003f0 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0103988:	83 ec 04             	sub    $0x4,%esp
c010398b:	6a 02                	push   $0x2
c010398d:	68 00 00 40 00       	push   $0x400000
c0103992:	6a 00                	push   $0x0
c0103994:	e8 3d f8 ff ff       	call   c01031d6 <vma_create>
c0103999:	83 c4 10             	add    $0x10,%esp
c010399c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c010399f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01039a3:	75 19                	jne    c01039be <check_pgfault+0xaf>
c01039a5:	68 fc 9d 10 c0       	push   $0xc0109dfc
c01039aa:	68 5b 9d 10 c0       	push   $0xc0109d5b
c01039af:	68 fc 00 00 00       	push   $0xfc
c01039b4:	68 70 9d 10 c0       	push   $0xc0109d70
c01039b9:	e8 32 ca ff ff       	call   c01003f0 <__panic>

    insert_vma_struct(mm, vma);
c01039be:	83 ec 08             	sub    $0x8,%esp
c01039c1:	ff 75 e0             	pushl  -0x20(%ebp)
c01039c4:	ff 75 e8             	pushl  -0x18(%ebp)
c01039c7:	e8 72 f9 ff ff       	call   c010333e <insert_vma_struct>
c01039cc:	83 c4 10             	add    $0x10,%esp

    uintptr_t addr = 0x100;
c01039cf:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c01039d6:	83 ec 08             	sub    $0x8,%esp
c01039d9:	ff 75 dc             	pushl  -0x24(%ebp)
c01039dc:	ff 75 e8             	pushl  -0x18(%ebp)
c01039df:	e8 2e f8 ff ff       	call   c0103212 <find_vma>
c01039e4:	83 c4 10             	add    $0x10,%esp
c01039e7:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01039ea:	74 19                	je     c0103a05 <check_pgfault+0xf6>
c01039ec:	68 79 9f 10 c0       	push   $0xc0109f79
c01039f1:	68 5b 9d 10 c0       	push   $0xc0109d5b
c01039f6:	68 01 01 00 00       	push   $0x101
c01039fb:	68 70 9d 10 c0       	push   $0xc0109d70
c0103a00:	e8 eb c9 ff ff       	call   c01003f0 <__panic>

    int i, sum = 0;
c0103a05:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0103a0c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103a13:	eb 19                	jmp    c0103a2e <check_pgfault+0x11f>
        *(char *)(addr + i) = i;
c0103a15:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103a18:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103a1b:	01 d0                	add    %edx,%eax
c0103a1d:	89 c2                	mov    %eax,%edx
c0103a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a22:	88 02                	mov    %al,(%edx)
        sum += i;
c0103a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a27:	01 45 f0             	add    %eax,-0x10(%ebp)

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
c0103a2a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103a2e:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0103a32:	7e e1                	jle    c0103a15 <check_pgfault+0x106>
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0103a34:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103a3b:	eb 15                	jmp    c0103a52 <check_pgfault+0x143>
        sum -= *(char *)(addr + i);
c0103a3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103a40:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103a43:	01 d0                	add    %edx,%eax
c0103a45:	0f b6 00             	movzbl (%eax),%eax
c0103a48:	0f be c0             	movsbl %al,%eax
c0103a4b:	29 45 f0             	sub    %eax,-0x10(%ebp)
    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0103a4e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103a52:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0103a56:	7e e5                	jle    c0103a3d <check_pgfault+0x12e>
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);
c0103a58:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103a5c:	74 19                	je     c0103a77 <check_pgfault+0x168>
c0103a5e:	68 93 9f 10 c0       	push   $0xc0109f93
c0103a63:	68 5b 9d 10 c0       	push   $0xc0109d5b
c0103a68:	68 0b 01 00 00       	push   $0x10b
c0103a6d:	68 70 9d 10 c0       	push   $0xc0109d70
c0103a72:	e8 79 c9 ff ff       	call   c01003f0 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0103a77:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103a7a:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0103a7d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103a80:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103a85:	83 ec 08             	sub    $0x8,%esp
c0103a88:	50                   	push   %eax
c0103a89:	ff 75 e4             	pushl  -0x1c(%ebp)
c0103a8c:	e8 a1 34 00 00       	call   c0106f32 <page_remove>
c0103a91:	83 c4 10             	add    $0x10,%esp
    free_page(pde2page(pgdir[0]));
c0103a94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103a97:	8b 00                	mov    (%eax),%eax
c0103a99:	83 ec 0c             	sub    $0xc,%esp
c0103a9c:	50                   	push   %eax
c0103a9d:	e8 9c f6 ff ff       	call   c010313e <pde2page>
c0103aa2:	83 c4 10             	add    $0x10,%esp
c0103aa5:	83 ec 08             	sub    $0x8,%esp
c0103aa8:	6a 01                	push   $0x1
c0103aaa:	50                   	push   %eax
c0103aab:	e8 9a 2c 00 00       	call   c010674a <free_pages>
c0103ab0:	83 c4 10             	add    $0x10,%esp
    pgdir[0] = 0;
c0103ab3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ab6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0103abc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103abf:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0103ac6:	83 ec 0c             	sub    $0xc,%esp
c0103ac9:	ff 75 e8             	pushl  -0x18(%ebp)
c0103acc:	e8 91 f9 ff ff       	call   c0103462 <mm_destroy>
c0103ad1:	83 c4 10             	add    $0x10,%esp
    check_mm_struct = NULL;
c0103ad4:	c7 05 58 a0 12 c0 00 	movl   $0x0,0xc012a058
c0103adb:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0103ade:	e8 9c 2c 00 00       	call   c010677f <nr_free_pages>
c0103ae3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103ae6:	74 19                	je     c0103b01 <check_pgfault+0x1f2>
c0103ae8:	68 9c 9f 10 c0       	push   $0xc0109f9c
c0103aed:	68 5b 9d 10 c0       	push   $0xc0109d5b
c0103af2:	68 15 01 00 00       	push   $0x115
c0103af7:	68 70 9d 10 c0       	push   $0xc0109d70
c0103afc:	e8 ef c8 ff ff       	call   c01003f0 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0103b01:	83 ec 0c             	sub    $0xc,%esp
c0103b04:	68 c3 9f 10 c0       	push   $0xc0109fc3
c0103b09:	e8 7c c7 ff ff       	call   c010028a <cprintf>
c0103b0e:	83 c4 10             	add    $0x10,%esp
}
c0103b11:	90                   	nop
c0103b12:	c9                   	leave  
c0103b13:	c3                   	ret    

c0103b14 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0103b14:	55                   	push   %ebp
c0103b15:	89 e5                	mov    %esp,%ebp
c0103b17:	83 ec 28             	sub    $0x28,%esp
    int ret = -E_INVAL;
c0103b1a:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0103b21:	ff 75 10             	pushl  0x10(%ebp)
c0103b24:	ff 75 08             	pushl  0x8(%ebp)
c0103b27:	e8 e6 f6 ff ff       	call   c0103212 <find_vma>
c0103b2c:	83 c4 08             	add    $0x8,%esp
c0103b2f:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c0103b32:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0103b37:	83 c0 01             	add    $0x1,%eax
c0103b3a:	a3 64 7f 12 c0       	mov    %eax,0xc0127f64
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c0103b3f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103b43:	74 0b                	je     c0103b50 <do_pgfault+0x3c>
c0103b45:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b48:	8b 40 04             	mov    0x4(%eax),%eax
c0103b4b:	3b 45 10             	cmp    0x10(%ebp),%eax
c0103b4e:	76 18                	jbe    c0103b68 <do_pgfault+0x54>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0103b50:	83 ec 08             	sub    $0x8,%esp
c0103b53:	ff 75 10             	pushl  0x10(%ebp)
c0103b56:	68 e0 9f 10 c0       	push   $0xc0109fe0
c0103b5b:	e8 2a c7 ff ff       	call   c010028a <cprintf>
c0103b60:	83 c4 10             	add    $0x10,%esp
        goto failed;
c0103b63:	e9 aa 01 00 00       	jmp    c0103d12 <do_pgfault+0x1fe>
    }
    //check the error_code
    switch (error_code & 3) {
c0103b68:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103b6b:	83 e0 03             	and    $0x3,%eax
c0103b6e:	85 c0                	test   %eax,%eax
c0103b70:	74 3c                	je     c0103bae <do_pgfault+0x9a>
c0103b72:	83 f8 01             	cmp    $0x1,%eax
c0103b75:	74 22                	je     c0103b99 <do_pgfault+0x85>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c0103b77:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b7a:	8b 40 0c             	mov    0xc(%eax),%eax
c0103b7d:	83 e0 02             	and    $0x2,%eax
c0103b80:	85 c0                	test   %eax,%eax
c0103b82:	75 4c                	jne    c0103bd0 <do_pgfault+0xbc>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0103b84:	83 ec 0c             	sub    $0xc,%esp
c0103b87:	68 10 a0 10 c0       	push   $0xc010a010
c0103b8c:	e8 f9 c6 ff ff       	call   c010028a <cprintf>
c0103b91:	83 c4 10             	add    $0x10,%esp
            goto failed;
c0103b94:	e9 79 01 00 00       	jmp    c0103d12 <do_pgfault+0x1fe>
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0103b99:	83 ec 0c             	sub    $0xc,%esp
c0103b9c:	68 70 a0 10 c0       	push   $0xc010a070
c0103ba1:	e8 e4 c6 ff ff       	call   c010028a <cprintf>
c0103ba6:	83 c4 10             	add    $0x10,%esp
        goto failed;
c0103ba9:	e9 64 01 00 00       	jmp    c0103d12 <do_pgfault+0x1fe>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0103bae:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103bb1:	8b 40 0c             	mov    0xc(%eax),%eax
c0103bb4:	83 e0 05             	and    $0x5,%eax
c0103bb7:	85 c0                	test   %eax,%eax
c0103bb9:	75 16                	jne    c0103bd1 <do_pgfault+0xbd>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0103bbb:	83 ec 0c             	sub    $0xc,%esp
c0103bbe:	68 a8 a0 10 c0       	push   $0xc010a0a8
c0103bc3:	e8 c2 c6 ff ff       	call   c010028a <cprintf>
c0103bc8:	83 c4 10             	add    $0x10,%esp
            goto failed;
c0103bcb:	e9 42 01 00 00       	jmp    c0103d12 <do_pgfault+0x1fe>
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
            goto failed;
        }
        break;
c0103bd0:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0103bd1:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0103bd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103bdb:	8b 40 0c             	mov    0xc(%eax),%eax
c0103bde:	83 e0 02             	and    $0x2,%eax
c0103be1:	85 c0                	test   %eax,%eax
c0103be3:	74 04                	je     c0103be9 <do_pgfault+0xd5>
        perm |= PTE_W;
c0103be5:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0103be9:	8b 45 10             	mov    0x10(%ebp),%eax
c0103bec:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103bef:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103bf2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103bf7:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0103bfa:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0103c01:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        }
   }
#endif
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c0103c08:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c0b:	8b 40 0c             	mov    0xc(%eax),%eax
c0103c0e:	83 ec 04             	sub    $0x4,%esp
c0103c11:	6a 01                	push   $0x1
c0103c13:	ff 75 10             	pushl  0x10(%ebp)
c0103c16:	50                   	push   %eax
c0103c17:	e8 3e 31 00 00       	call   c0106d5a <get_pte>
c0103c1c:	83 c4 10             	add    $0x10,%esp
c0103c1f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103c22:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103c26:	75 15                	jne    c0103c3d <do_pgfault+0x129>
        cprintf("get_pte in do_pgfault failed\n");
c0103c28:	83 ec 0c             	sub    $0xc,%esp
c0103c2b:	68 0b a1 10 c0       	push   $0xc010a10b
c0103c30:	e8 55 c6 ff ff       	call   c010028a <cprintf>
c0103c35:	83 c4 10             	add    $0x10,%esp
        goto failed;
c0103c38:	e9 d5 00 00 00       	jmp    c0103d12 <do_pgfault+0x1fe>
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
c0103c3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103c40:	8b 00                	mov    (%eax),%eax
c0103c42:	85 c0                	test   %eax,%eax
c0103c44:	75 35                	jne    c0103c7b <do_pgfault+0x167>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c0103c46:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c49:	8b 40 0c             	mov    0xc(%eax),%eax
c0103c4c:	83 ec 04             	sub    $0x4,%esp
c0103c4f:	ff 75 f0             	pushl  -0x10(%ebp)
c0103c52:	ff 75 10             	pushl  0x10(%ebp)
c0103c55:	50                   	push   %eax
c0103c56:	e8 19 34 00 00       	call   c0107074 <pgdir_alloc_page>
c0103c5b:	83 c4 10             	add    $0x10,%esp
c0103c5e:	85 c0                	test   %eax,%eax
c0103c60:	0f 85 a5 00 00 00    	jne    c0103d0b <do_pgfault+0x1f7>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c0103c66:	83 ec 0c             	sub    $0xc,%esp
c0103c69:	68 2c a1 10 c0       	push   $0xc010a12c
c0103c6e:	e8 17 c6 ff ff       	call   c010028a <cprintf>
c0103c73:	83 c4 10             	add    $0x10,%esp
            goto failed;
c0103c76:	e9 97 00 00 00       	jmp    c0103d12 <do_pgfault+0x1fe>
        }
    }
    else { // if this pte is a swap entry, then load data from disk to a page with phy addr
           // and call page_insert to map the phy addr with logical addr
        if(swap_init_ok) {
c0103c7b:	a1 6c 7f 12 c0       	mov    0xc0127f6c,%eax
c0103c80:	85 c0                	test   %eax,%eax
c0103c82:	74 6f                	je     c0103cf3 <do_pgfault+0x1df>
            struct Page *page=NULL;
c0103c84:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c0103c8b:	83 ec 04             	sub    $0x4,%esp
c0103c8e:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0103c91:	50                   	push   %eax
c0103c92:	ff 75 10             	pushl  0x10(%ebp)
c0103c95:	ff 75 08             	pushl  0x8(%ebp)
c0103c98:	e8 3b 0f 00 00       	call   c0104bd8 <swap_in>
c0103c9d:	83 c4 10             	add    $0x10,%esp
c0103ca0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103ca3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103ca7:	74 12                	je     c0103cbb <do_pgfault+0x1a7>
                cprintf("swap_in in do_pgfault failed\n");
c0103ca9:	83 ec 0c             	sub    $0xc,%esp
c0103cac:	68 53 a1 10 c0       	push   $0xc010a153
c0103cb1:	e8 d4 c5 ff ff       	call   c010028a <cprintf>
c0103cb6:	83 c4 10             	add    $0x10,%esp
c0103cb9:	eb 57                	jmp    c0103d12 <do_pgfault+0x1fe>
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);
c0103cbb:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103cbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0103cc1:	8b 40 0c             	mov    0xc(%eax),%eax
c0103cc4:	ff 75 f0             	pushl  -0x10(%ebp)
c0103cc7:	ff 75 10             	pushl  0x10(%ebp)
c0103cca:	52                   	push   %edx
c0103ccb:	50                   	push   %eax
c0103ccc:	e8 9a 32 00 00       	call   c0106f6b <page_insert>
c0103cd1:	83 c4 10             	add    $0x10,%esp
            swap_map_swappable(mm, addr, page, 1);
c0103cd4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103cd7:	6a 01                	push   $0x1
c0103cd9:	50                   	push   %eax
c0103cda:	ff 75 10             	pushl  0x10(%ebp)
c0103cdd:	ff 75 08             	pushl  0x8(%ebp)
c0103ce0:	e8 63 0d 00 00       	call   c0104a48 <swap_map_swappable>
c0103ce5:	83 c4 10             	add    $0x10,%esp
            page->pra_vaddr = addr;
c0103ce8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103ceb:	8b 55 10             	mov    0x10(%ebp),%edx
c0103cee:	89 50 20             	mov    %edx,0x20(%eax)
c0103cf1:	eb 18                	jmp    c0103d0b <do_pgfault+0x1f7>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c0103cf3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103cf6:	8b 00                	mov    (%eax),%eax
c0103cf8:	83 ec 08             	sub    $0x8,%esp
c0103cfb:	50                   	push   %eax
c0103cfc:	68 74 a1 10 c0       	push   $0xc010a174
c0103d01:	e8 84 c5 ff ff       	call   c010028a <cprintf>
c0103d06:	83 c4 10             	add    $0x10,%esp
            goto failed;
c0103d09:	eb 07                	jmp    c0103d12 <do_pgfault+0x1fe>
        }
   }
   ret = 0;
c0103d0b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c0103d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103d15:	c9                   	leave  
c0103d16:	c3                   	ret    

c0103d17 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0103d17:	55                   	push   %ebp
c0103d18:	89 e5                	mov    %esp,%ebp
c0103d1a:	83 ec 10             	sub    $0x10,%esp
c0103d1d:	c7 45 fc 5c a0 12 c0 	movl   $0xc012a05c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103d24:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103d27:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103d2a:	89 50 04             	mov    %edx,0x4(%eax)
c0103d2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103d30:	8b 50 04             	mov    0x4(%eax),%edx
c0103d33:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103d36:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0103d38:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d3b:	c7 40 14 5c a0 12 c0 	movl   $0xc012a05c,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c0103d42:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103d47:	c9                   	leave  
c0103d48:	c3                   	ret    

c0103d49 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0103d49:	55                   	push   %ebp
c0103d4a:	89 e5                	mov    %esp,%ebp
c0103d4c:	83 ec 38             	sub    $0x38,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0103d4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d52:	8b 40 14             	mov    0x14(%eax),%eax
c0103d55:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0103d58:	8b 45 10             	mov    0x10(%ebp),%eax
c0103d5b:	83 c0 18             	add    $0x18,%eax
c0103d5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c0103d61:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103d65:	74 06                	je     c0103d6d <_fifo_map_swappable+0x24>
c0103d67:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103d6b:	75 16                	jne    c0103d83 <_fifo_map_swappable+0x3a>
c0103d6d:	68 9c a1 10 c0       	push   $0xc010a19c
c0103d72:	68 ba a1 10 c0       	push   $0xc010a1ba
c0103d77:	6a 32                	push   $0x32
c0103d79:	68 cf a1 10 c0       	push   $0xc010a1cf
c0103d7e:	e8 6d c6 ff ff       	call   c01003f0 <__panic>
c0103d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d86:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103d89:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d8c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103d8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d92:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103d95:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103d98:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0103d9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d9e:	8b 40 04             	mov    0x4(%eax),%eax
c0103da1:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103da4:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0103da7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103daa:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0103dad:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103db0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103db3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103db6:	89 10                	mov    %edx,(%eax)
c0103db8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103dbb:	8b 10                	mov    (%eax),%edx
c0103dbd:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103dc0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103dc3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103dc6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103dc9:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103dcc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103dcf:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103dd2:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c0103dd4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103dd9:	c9                   	leave  
c0103dda:	c3                   	ret    

c0103ddb <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0103ddb:	55                   	push   %ebp
c0103ddc:	89 e5                	mov    %esp,%ebp
c0103dde:	83 ec 28             	sub    $0x28,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0103de1:	8b 45 08             	mov    0x8(%ebp),%eax
c0103de4:	8b 40 14             	mov    0x14(%eax),%eax
c0103de7:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c0103dea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103dee:	75 16                	jne    c0103e06 <_fifo_swap_out_victim+0x2b>
c0103df0:	68 e3 a1 10 c0       	push   $0xc010a1e3
c0103df5:	68 ba a1 10 c0       	push   $0xc010a1ba
c0103dfa:	6a 41                	push   $0x41
c0103dfc:	68 cf a1 10 c0       	push   $0xc010a1cf
c0103e01:	e8 ea c5 ff ff       	call   c01003f0 <__panic>
     assert(in_tick==0);
c0103e06:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103e0a:	74 16                	je     c0103e22 <_fifo_swap_out_victim+0x47>
c0103e0c:	68 f0 a1 10 c0       	push   $0xc010a1f0
c0103e11:	68 ba a1 10 c0       	push   $0xc010a1ba
c0103e16:	6a 42                	push   $0x42
c0103e18:	68 cf a1 10 c0       	push   $0xc010a1cf
c0103e1d:	e8 ce c5 ff ff       	call   c01003f0 <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
     /* Select the tail */
     list_entry_t *le = head->prev;
c0103e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e25:	8b 00                	mov    (%eax),%eax
c0103e27:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c0103e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e2d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103e30:	75 16                	jne    c0103e48 <_fifo_swap_out_victim+0x6d>
c0103e32:	68 fb a1 10 c0       	push   $0xc010a1fb
c0103e37:	68 ba a1 10 c0       	push   $0xc010a1ba
c0103e3c:	6a 49                	push   $0x49
c0103e3e:	68 cf a1 10 c0       	push   $0xc010a1cf
c0103e43:	e8 a8 c5 ff ff       	call   c01003f0 <__panic>
     struct Page *p = le2page(le, pra_page_link);
c0103e48:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e4b:	83 e8 18             	sub    $0x18,%eax
c0103e4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103e51:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e54:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103e57:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103e5a:	8b 40 04             	mov    0x4(%eax),%eax
c0103e5d:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0103e60:	8b 12                	mov    (%edx),%edx
c0103e62:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0103e65:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103e68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e6b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103e6e:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103e71:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103e74:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103e77:	89 10                	mov    %edx,(%eax)
     list_del(le);
     assert(p !=NULL);
c0103e79:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103e7d:	75 16                	jne    c0103e95 <_fifo_swap_out_victim+0xba>
c0103e7f:	68 04 a2 10 c0       	push   $0xc010a204
c0103e84:	68 ba a1 10 c0       	push   $0xc010a1ba
c0103e89:	6a 4c                	push   $0x4c
c0103e8b:	68 cf a1 10 c0       	push   $0xc010a1cf
c0103e90:	e8 5b c5 ff ff       	call   c01003f0 <__panic>
     *ptr_page = p;
c0103e95:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103e98:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103e9b:	89 10                	mov    %edx,(%eax)
     return 0;
c0103e9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103ea2:	c9                   	leave  
c0103ea3:	c3                   	ret    

c0103ea4 <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0103ea4:	55                   	push   %ebp
c0103ea5:	89 e5                	mov    %esp,%ebp
c0103ea7:	83 ec 08             	sub    $0x8,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0103eaa:	83 ec 0c             	sub    $0xc,%esp
c0103ead:	68 10 a2 10 c0       	push   $0xc010a210
c0103eb2:	e8 d3 c3 ff ff       	call   c010028a <cprintf>
c0103eb7:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x3000 = 0x0c;
c0103eba:	b8 00 30 00 00       	mov    $0x3000,%eax
c0103ebf:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c0103ec2:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0103ec7:	83 f8 04             	cmp    $0x4,%eax
c0103eca:	74 16                	je     c0103ee2 <_fifo_check_swap+0x3e>
c0103ecc:	68 36 a2 10 c0       	push   $0xc010a236
c0103ed1:	68 ba a1 10 c0       	push   $0xc010a1ba
c0103ed6:	6a 55                	push   $0x55
c0103ed8:	68 cf a1 10 c0       	push   $0xc010a1cf
c0103edd:	e8 0e c5 ff ff       	call   c01003f0 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0103ee2:	83 ec 0c             	sub    $0xc,%esp
c0103ee5:	68 48 a2 10 c0       	push   $0xc010a248
c0103eea:	e8 9b c3 ff ff       	call   c010028a <cprintf>
c0103eef:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x1000 = 0x0a;
c0103ef2:	b8 00 10 00 00       	mov    $0x1000,%eax
c0103ef7:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c0103efa:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0103eff:	83 f8 04             	cmp    $0x4,%eax
c0103f02:	74 16                	je     c0103f1a <_fifo_check_swap+0x76>
c0103f04:	68 36 a2 10 c0       	push   $0xc010a236
c0103f09:	68 ba a1 10 c0       	push   $0xc010a1ba
c0103f0e:	6a 58                	push   $0x58
c0103f10:	68 cf a1 10 c0       	push   $0xc010a1cf
c0103f15:	e8 d6 c4 ff ff       	call   c01003f0 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0103f1a:	83 ec 0c             	sub    $0xc,%esp
c0103f1d:	68 70 a2 10 c0       	push   $0xc010a270
c0103f22:	e8 63 c3 ff ff       	call   c010028a <cprintf>
c0103f27:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x4000 = 0x0d;
c0103f2a:	b8 00 40 00 00       	mov    $0x4000,%eax
c0103f2f:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0103f32:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0103f37:	83 f8 04             	cmp    $0x4,%eax
c0103f3a:	74 16                	je     c0103f52 <_fifo_check_swap+0xae>
c0103f3c:	68 36 a2 10 c0       	push   $0xc010a236
c0103f41:	68 ba a1 10 c0       	push   $0xc010a1ba
c0103f46:	6a 5b                	push   $0x5b
c0103f48:	68 cf a1 10 c0       	push   $0xc010a1cf
c0103f4d:	e8 9e c4 ff ff       	call   c01003f0 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0103f52:	83 ec 0c             	sub    $0xc,%esp
c0103f55:	68 98 a2 10 c0       	push   $0xc010a298
c0103f5a:	e8 2b c3 ff ff       	call   c010028a <cprintf>
c0103f5f:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c0103f62:	b8 00 20 00 00       	mov    $0x2000,%eax
c0103f67:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c0103f6a:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0103f6f:	83 f8 04             	cmp    $0x4,%eax
c0103f72:	74 16                	je     c0103f8a <_fifo_check_swap+0xe6>
c0103f74:	68 36 a2 10 c0       	push   $0xc010a236
c0103f79:	68 ba a1 10 c0       	push   $0xc010a1ba
c0103f7e:	6a 5e                	push   $0x5e
c0103f80:	68 cf a1 10 c0       	push   $0xc010a1cf
c0103f85:	e8 66 c4 ff ff       	call   c01003f0 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0103f8a:	83 ec 0c             	sub    $0xc,%esp
c0103f8d:	68 c0 a2 10 c0       	push   $0xc010a2c0
c0103f92:	e8 f3 c2 ff ff       	call   c010028a <cprintf>
c0103f97:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x5000 = 0x0e;
c0103f9a:	b8 00 50 00 00       	mov    $0x5000,%eax
c0103f9f:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0103fa2:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0103fa7:	83 f8 05             	cmp    $0x5,%eax
c0103faa:	74 16                	je     c0103fc2 <_fifo_check_swap+0x11e>
c0103fac:	68 e6 a2 10 c0       	push   $0xc010a2e6
c0103fb1:	68 ba a1 10 c0       	push   $0xc010a1ba
c0103fb6:	6a 61                	push   $0x61
c0103fb8:	68 cf a1 10 c0       	push   $0xc010a1cf
c0103fbd:	e8 2e c4 ff ff       	call   c01003f0 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0103fc2:	83 ec 0c             	sub    $0xc,%esp
c0103fc5:	68 98 a2 10 c0       	push   $0xc010a298
c0103fca:	e8 bb c2 ff ff       	call   c010028a <cprintf>
c0103fcf:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c0103fd2:	b8 00 20 00 00       	mov    $0x2000,%eax
c0103fd7:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0103fda:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0103fdf:	83 f8 05             	cmp    $0x5,%eax
c0103fe2:	74 16                	je     c0103ffa <_fifo_check_swap+0x156>
c0103fe4:	68 e6 a2 10 c0       	push   $0xc010a2e6
c0103fe9:	68 ba a1 10 c0       	push   $0xc010a1ba
c0103fee:	6a 64                	push   $0x64
c0103ff0:	68 cf a1 10 c0       	push   $0xc010a1cf
c0103ff5:	e8 f6 c3 ff ff       	call   c01003f0 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0103ffa:	83 ec 0c             	sub    $0xc,%esp
c0103ffd:	68 48 a2 10 c0       	push   $0xc010a248
c0104002:	e8 83 c2 ff ff       	call   c010028a <cprintf>
c0104007:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x1000 = 0x0a;
c010400a:	b8 00 10 00 00       	mov    $0x1000,%eax
c010400f:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0104012:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0104017:	83 f8 06             	cmp    $0x6,%eax
c010401a:	74 16                	je     c0104032 <_fifo_check_swap+0x18e>
c010401c:	68 f5 a2 10 c0       	push   $0xc010a2f5
c0104021:	68 ba a1 10 c0       	push   $0xc010a1ba
c0104026:	6a 67                	push   $0x67
c0104028:	68 cf a1 10 c0       	push   $0xc010a1cf
c010402d:	e8 be c3 ff ff       	call   c01003f0 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0104032:	83 ec 0c             	sub    $0xc,%esp
c0104035:	68 98 a2 10 c0       	push   $0xc010a298
c010403a:	e8 4b c2 ff ff       	call   c010028a <cprintf>
c010403f:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c0104042:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104047:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c010404a:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c010404f:	83 f8 07             	cmp    $0x7,%eax
c0104052:	74 16                	je     c010406a <_fifo_check_swap+0x1c6>
c0104054:	68 04 a3 10 c0       	push   $0xc010a304
c0104059:	68 ba a1 10 c0       	push   $0xc010a1ba
c010405e:	6a 6a                	push   $0x6a
c0104060:	68 cf a1 10 c0       	push   $0xc010a1cf
c0104065:	e8 86 c3 ff ff       	call   c01003f0 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c010406a:	83 ec 0c             	sub    $0xc,%esp
c010406d:	68 10 a2 10 c0       	push   $0xc010a210
c0104072:	e8 13 c2 ff ff       	call   c010028a <cprintf>
c0104077:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x3000 = 0x0c;
c010407a:	b8 00 30 00 00       	mov    $0x3000,%eax
c010407f:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c0104082:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0104087:	83 f8 08             	cmp    $0x8,%eax
c010408a:	74 16                	je     c01040a2 <_fifo_check_swap+0x1fe>
c010408c:	68 13 a3 10 c0       	push   $0xc010a313
c0104091:	68 ba a1 10 c0       	push   $0xc010a1ba
c0104096:	6a 6d                	push   $0x6d
c0104098:	68 cf a1 10 c0       	push   $0xc010a1cf
c010409d:	e8 4e c3 ff ff       	call   c01003f0 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c01040a2:	83 ec 0c             	sub    $0xc,%esp
c01040a5:	68 70 a2 10 c0       	push   $0xc010a270
c01040aa:	e8 db c1 ff ff       	call   c010028a <cprintf>
c01040af:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x4000 = 0x0d;
c01040b2:	b8 00 40 00 00       	mov    $0x4000,%eax
c01040b7:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c01040ba:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c01040bf:	83 f8 09             	cmp    $0x9,%eax
c01040c2:	74 16                	je     c01040da <_fifo_check_swap+0x236>
c01040c4:	68 22 a3 10 c0       	push   $0xc010a322
c01040c9:	68 ba a1 10 c0       	push   $0xc010a1ba
c01040ce:	6a 70                	push   $0x70
c01040d0:	68 cf a1 10 c0       	push   $0xc010a1cf
c01040d5:	e8 16 c3 ff ff       	call   c01003f0 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c01040da:	83 ec 0c             	sub    $0xc,%esp
c01040dd:	68 c0 a2 10 c0       	push   $0xc010a2c0
c01040e2:	e8 a3 c1 ff ff       	call   c010028a <cprintf>
c01040e7:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x5000 = 0x0e;
c01040ea:	b8 00 50 00 00       	mov    $0x5000,%eax
c01040ef:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c01040f2:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c01040f7:	83 f8 0a             	cmp    $0xa,%eax
c01040fa:	74 16                	je     c0104112 <_fifo_check_swap+0x26e>
c01040fc:	68 31 a3 10 c0       	push   $0xc010a331
c0104101:	68 ba a1 10 c0       	push   $0xc010a1ba
c0104106:	6a 73                	push   $0x73
c0104108:	68 cf a1 10 c0       	push   $0xc010a1cf
c010410d:	e8 de c2 ff ff       	call   c01003f0 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0104112:	83 ec 0c             	sub    $0xc,%esp
c0104115:	68 48 a2 10 c0       	push   $0xc010a248
c010411a:	e8 6b c1 ff ff       	call   c010028a <cprintf>
c010411f:	83 c4 10             	add    $0x10,%esp
    assert(*(unsigned char *)0x1000 == 0x0a);
c0104122:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104127:	0f b6 00             	movzbl (%eax),%eax
c010412a:	3c 0a                	cmp    $0xa,%al
c010412c:	74 16                	je     c0104144 <_fifo_check_swap+0x2a0>
c010412e:	68 44 a3 10 c0       	push   $0xc010a344
c0104133:	68 ba a1 10 c0       	push   $0xc010a1ba
c0104138:	6a 75                	push   $0x75
c010413a:	68 cf a1 10 c0       	push   $0xc010a1cf
c010413f:	e8 ac c2 ff ff       	call   c01003f0 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c0104144:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104149:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c010414c:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0104151:	83 f8 0b             	cmp    $0xb,%eax
c0104154:	74 16                	je     c010416c <_fifo_check_swap+0x2c8>
c0104156:	68 65 a3 10 c0       	push   $0xc010a365
c010415b:	68 ba a1 10 c0       	push   $0xc010a1ba
c0104160:	6a 77                	push   $0x77
c0104162:	68 cf a1 10 c0       	push   $0xc010a1cf
c0104167:	e8 84 c2 ff ff       	call   c01003f0 <__panic>
    return 0;
c010416c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104171:	c9                   	leave  
c0104172:	c3                   	ret    

c0104173 <_fifo_init>:


static int
_fifo_init(void)
{
c0104173:	55                   	push   %ebp
c0104174:	89 e5                	mov    %esp,%ebp
    return 0;
c0104176:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010417b:	5d                   	pop    %ebp
c010417c:	c3                   	ret    

c010417d <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c010417d:	55                   	push   %ebp
c010417e:	89 e5                	mov    %esp,%ebp
    return 0;
c0104180:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104185:	5d                   	pop    %ebp
c0104186:	c3                   	ret    

c0104187 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c0104187:	55                   	push   %ebp
c0104188:	89 e5                	mov    %esp,%ebp
c010418a:	b8 00 00 00 00       	mov    $0x0,%eax
c010418f:	5d                   	pop    %ebp
c0104190:	c3                   	ret    

c0104191 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0104191:	55                   	push   %ebp
c0104192:	89 e5                	mov    %esp,%ebp
c0104194:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0104197:	9c                   	pushf  
c0104198:	58                   	pop    %eax
c0104199:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010419c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010419f:	25 00 02 00 00       	and    $0x200,%eax
c01041a4:	85 c0                	test   %eax,%eax
c01041a6:	74 0c                	je     c01041b4 <__intr_save+0x23>
        intr_disable();
c01041a8:	e8 65 de ff ff       	call   c0102012 <intr_disable>
        return 1;
c01041ad:	b8 01 00 00 00       	mov    $0x1,%eax
c01041b2:	eb 05                	jmp    c01041b9 <__intr_save+0x28>
    }
    return 0;
c01041b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01041b9:	c9                   	leave  
c01041ba:	c3                   	ret    

c01041bb <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01041bb:	55                   	push   %ebp
c01041bc:	89 e5                	mov    %esp,%ebp
c01041be:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01041c1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01041c5:	74 05                	je     c01041cc <__intr_restore+0x11>
        intr_enable();
c01041c7:	e8 3f de ff ff       	call   c010200b <intr_enable>
    }
}
c01041cc:	90                   	nop
c01041cd:	c9                   	leave  
c01041ce:	c3                   	ret    

c01041cf <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01041cf:	55                   	push   %ebp
c01041d0:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01041d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01041d5:	8b 15 58 a1 12 c0    	mov    0xc012a158,%edx
c01041db:	29 d0                	sub    %edx,%eax
c01041dd:	c1 f8 02             	sar    $0x2,%eax
c01041e0:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c01041e6:	5d                   	pop    %ebp
c01041e7:	c3                   	ret    

c01041e8 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01041e8:	55                   	push   %ebp
c01041e9:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c01041eb:	ff 75 08             	pushl  0x8(%ebp)
c01041ee:	e8 dc ff ff ff       	call   c01041cf <page2ppn>
c01041f3:	83 c4 04             	add    $0x4,%esp
c01041f6:	c1 e0 0c             	shl    $0xc,%eax
}
c01041f9:	c9                   	leave  
c01041fa:	c3                   	ret    

c01041fb <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c01041fb:	55                   	push   %ebp
c01041fc:	89 e5                	mov    %esp,%ebp
c01041fe:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0104201:	8b 45 08             	mov    0x8(%ebp),%eax
c0104204:	c1 e8 0c             	shr    $0xc,%eax
c0104207:	89 c2                	mov    %eax,%edx
c0104209:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c010420e:	39 c2                	cmp    %eax,%edx
c0104210:	72 14                	jb     c0104226 <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0104212:	83 ec 04             	sub    $0x4,%esp
c0104215:	68 88 a3 10 c0       	push   $0xc010a388
c010421a:	6a 5f                	push   $0x5f
c010421c:	68 a7 a3 10 c0       	push   $0xc010a3a7
c0104221:	e8 ca c1 ff ff       	call   c01003f0 <__panic>
    }
    return &pages[PPN(pa)];
c0104226:	8b 0d 58 a1 12 c0    	mov    0xc012a158,%ecx
c010422c:	8b 45 08             	mov    0x8(%ebp),%eax
c010422f:	c1 e8 0c             	shr    $0xc,%eax
c0104232:	89 c2                	mov    %eax,%edx
c0104234:	89 d0                	mov    %edx,%eax
c0104236:	c1 e0 03             	shl    $0x3,%eax
c0104239:	01 d0                	add    %edx,%eax
c010423b:	c1 e0 02             	shl    $0x2,%eax
c010423e:	01 c8                	add    %ecx,%eax
}
c0104240:	c9                   	leave  
c0104241:	c3                   	ret    

c0104242 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0104242:	55                   	push   %ebp
c0104243:	89 e5                	mov    %esp,%ebp
c0104245:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c0104248:	ff 75 08             	pushl  0x8(%ebp)
c010424b:	e8 98 ff ff ff       	call   c01041e8 <page2pa>
c0104250:	83 c4 04             	add    $0x4,%esp
c0104253:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104256:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104259:	c1 e8 0c             	shr    $0xc,%eax
c010425c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010425f:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0104264:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104267:	72 14                	jb     c010427d <page2kva+0x3b>
c0104269:	ff 75 f4             	pushl  -0xc(%ebp)
c010426c:	68 b8 a3 10 c0       	push   $0xc010a3b8
c0104271:	6a 66                	push   $0x66
c0104273:	68 a7 a3 10 c0       	push   $0xc010a3a7
c0104278:	e8 73 c1 ff ff       	call   c01003f0 <__panic>
c010427d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104280:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104285:	c9                   	leave  
c0104286:	c3                   	ret    

c0104287 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c0104287:	55                   	push   %ebp
c0104288:	89 e5                	mov    %esp,%ebp
c010428a:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PADDR(kva));
c010428d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104290:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104293:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010429a:	77 14                	ja     c01042b0 <kva2page+0x29>
c010429c:	ff 75 f4             	pushl  -0xc(%ebp)
c010429f:	68 dc a3 10 c0       	push   $0xc010a3dc
c01042a4:	6a 6b                	push   $0x6b
c01042a6:	68 a7 a3 10 c0       	push   $0xc010a3a7
c01042ab:	e8 40 c1 ff ff       	call   c01003f0 <__panic>
c01042b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01042b3:	05 00 00 00 40       	add    $0x40000000,%eax
c01042b8:	83 ec 0c             	sub    $0xc,%esp
c01042bb:	50                   	push   %eax
c01042bc:	e8 3a ff ff ff       	call   c01041fb <pa2page>
c01042c1:	83 c4 10             	add    $0x10,%esp
}
c01042c4:	c9                   	leave  
c01042c5:	c3                   	ret    

c01042c6 <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c01042c6:	55                   	push   %ebp
c01042c7:	89 e5                	mov    %esp,%ebp
c01042c9:	83 ec 18             	sub    $0x18,%esp
  struct Page * page = alloc_pages(1 << order);
c01042cc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01042cf:	ba 01 00 00 00       	mov    $0x1,%edx
c01042d4:	89 c1                	mov    %eax,%ecx
c01042d6:	d3 e2                	shl    %cl,%edx
c01042d8:	89 d0                	mov    %edx,%eax
c01042da:	83 ec 0c             	sub    $0xc,%esp
c01042dd:	50                   	push   %eax
c01042de:	e8 fb 23 00 00       	call   c01066de <alloc_pages>
c01042e3:	83 c4 10             	add    $0x10,%esp
c01042e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c01042e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01042ed:	75 07                	jne    c01042f6 <__slob_get_free_pages+0x30>
    return NULL;
c01042ef:	b8 00 00 00 00       	mov    $0x0,%eax
c01042f4:	eb 0e                	jmp    c0104304 <__slob_get_free_pages+0x3e>
  return page2kva(page);
c01042f6:	83 ec 0c             	sub    $0xc,%esp
c01042f9:	ff 75 f4             	pushl  -0xc(%ebp)
c01042fc:	e8 41 ff ff ff       	call   c0104242 <page2kva>
c0104301:	83 c4 10             	add    $0x10,%esp
}
c0104304:	c9                   	leave  
c0104305:	c3                   	ret    

c0104306 <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c0104306:	55                   	push   %ebp
c0104307:	89 e5                	mov    %esp,%ebp
c0104309:	53                   	push   %ebx
c010430a:	83 ec 04             	sub    $0x4,%esp
  free_pages(kva2page(kva), 1 << order);
c010430d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104310:	ba 01 00 00 00       	mov    $0x1,%edx
c0104315:	89 c1                	mov    %eax,%ecx
c0104317:	d3 e2                	shl    %cl,%edx
c0104319:	89 d0                	mov    %edx,%eax
c010431b:	89 c3                	mov    %eax,%ebx
c010431d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104320:	83 ec 0c             	sub    $0xc,%esp
c0104323:	50                   	push   %eax
c0104324:	e8 5e ff ff ff       	call   c0104287 <kva2page>
c0104329:	83 c4 10             	add    $0x10,%esp
c010432c:	83 ec 08             	sub    $0x8,%esp
c010432f:	53                   	push   %ebx
c0104330:	50                   	push   %eax
c0104331:	e8 14 24 00 00       	call   c010674a <free_pages>
c0104336:	83 c4 10             	add    $0x10,%esp
}
c0104339:	90                   	nop
c010433a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010433d:	c9                   	leave  
c010433e:	c3                   	ret    

c010433f <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c010433f:	55                   	push   %ebp
c0104340:	89 e5                	mov    %esp,%ebp
c0104342:	83 ec 28             	sub    $0x28,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c0104345:	8b 45 08             	mov    0x8(%ebp),%eax
c0104348:	83 c0 08             	add    $0x8,%eax
c010434b:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0104350:	76 16                	jbe    c0104368 <slob_alloc+0x29>
c0104352:	68 00 a4 10 c0       	push   $0xc010a400
c0104357:	68 1f a4 10 c0       	push   $0xc010a41f
c010435c:	6a 64                	push   $0x64
c010435e:	68 34 a4 10 c0       	push   $0xc010a434
c0104363:	e8 88 c0 ff ff       	call   c01003f0 <__panic>

	slob_t *prev, *cur, *aligned = 0;
c0104368:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c010436f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0104376:	8b 45 08             	mov    0x8(%ebp),%eax
c0104379:	83 c0 07             	add    $0x7,%eax
c010437c:	c1 e8 03             	shr    $0x3,%eax
c010437f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c0104382:	e8 0a fe ff ff       	call   c0104191 <__intr_save>
c0104387:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c010438a:	a1 08 4a 12 c0       	mov    0xc0124a08,%eax
c010438f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0104392:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104395:	8b 40 04             	mov    0x4(%eax),%eax
c0104398:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c010439b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010439f:	74 25                	je     c01043c6 <slob_alloc+0x87>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c01043a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01043a4:	8b 45 10             	mov    0x10(%ebp),%eax
c01043a7:	01 d0                	add    %edx,%eax
c01043a9:	8d 50 ff             	lea    -0x1(%eax),%edx
c01043ac:	8b 45 10             	mov    0x10(%ebp),%eax
c01043af:	f7 d8                	neg    %eax
c01043b1:	21 d0                	and    %edx,%eax
c01043b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c01043b6:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01043b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043bc:	29 c2                	sub    %eax,%edx
c01043be:	89 d0                	mov    %edx,%eax
c01043c0:	c1 f8 03             	sar    $0x3,%eax
c01043c3:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c01043c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043c9:	8b 00                	mov    (%eax),%eax
c01043cb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c01043ce:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01043d1:	01 ca                	add    %ecx,%edx
c01043d3:	39 d0                	cmp    %edx,%eax
c01043d5:	0f 8c b1 00 00 00    	jl     c010448c <slob_alloc+0x14d>
			if (delta) { /* need to fragment head to align? */
c01043db:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01043df:	74 38                	je     c0104419 <slob_alloc+0xda>
				aligned->units = cur->units - delta;
c01043e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043e4:	8b 00                	mov    (%eax),%eax
c01043e6:	2b 45 e8             	sub    -0x18(%ebp),%eax
c01043e9:	89 c2                	mov    %eax,%edx
c01043eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01043ee:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c01043f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043f3:	8b 50 04             	mov    0x4(%eax),%edx
c01043f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01043f9:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c01043fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043ff:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104402:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c0104405:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104408:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010440b:	89 10                	mov    %edx,(%eax)
				prev = cur;
c010440d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104410:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c0104413:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104416:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c0104419:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010441c:	8b 00                	mov    (%eax),%eax
c010441e:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0104421:	75 0e                	jne    c0104431 <slob_alloc+0xf2>
				prev->next = cur->next; /* unlink */
c0104423:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104426:	8b 50 04             	mov    0x4(%eax),%edx
c0104429:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010442c:	89 50 04             	mov    %edx,0x4(%eax)
c010442f:	eb 3c                	jmp    c010446d <slob_alloc+0x12e>
			else { /* fragment */
				prev->next = cur + units;
c0104431:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104434:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010443b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010443e:	01 c2                	add    %eax,%edx
c0104440:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104443:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c0104446:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104449:	8b 40 04             	mov    0x4(%eax),%eax
c010444c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010444f:	8b 12                	mov    (%edx),%edx
c0104451:	2b 55 e0             	sub    -0x20(%ebp),%edx
c0104454:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c0104456:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104459:	8b 40 04             	mov    0x4(%eax),%eax
c010445c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010445f:	8b 52 04             	mov    0x4(%edx),%edx
c0104462:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c0104465:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104468:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010446b:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c010446d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104470:	a3 08 4a 12 c0       	mov    %eax,0xc0124a08
			spin_unlock_irqrestore(&slob_lock, flags);
c0104475:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104478:	83 ec 0c             	sub    $0xc,%esp
c010447b:	50                   	push   %eax
c010447c:	e8 3a fd ff ff       	call   c01041bb <__intr_restore>
c0104481:	83 c4 10             	add    $0x10,%esp
			return cur;
c0104484:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104487:	e9 80 00 00 00       	jmp    c010450c <slob_alloc+0x1cd>
		}
		if (cur == slobfree) {
c010448c:	a1 08 4a 12 c0       	mov    0xc0124a08,%eax
c0104491:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104494:	75 62                	jne    c01044f8 <slob_alloc+0x1b9>
			spin_unlock_irqrestore(&slob_lock, flags);
c0104496:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104499:	83 ec 0c             	sub    $0xc,%esp
c010449c:	50                   	push   %eax
c010449d:	e8 19 fd ff ff       	call   c01041bb <__intr_restore>
c01044a2:	83 c4 10             	add    $0x10,%esp

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c01044a5:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c01044ac:	75 07                	jne    c01044b5 <slob_alloc+0x176>
				return 0;
c01044ae:	b8 00 00 00 00       	mov    $0x0,%eax
c01044b3:	eb 57                	jmp    c010450c <slob_alloc+0x1cd>

			cur = (slob_t *)__slob_get_free_page(gfp);
c01044b5:	83 ec 08             	sub    $0x8,%esp
c01044b8:	6a 00                	push   $0x0
c01044ba:	ff 75 0c             	pushl  0xc(%ebp)
c01044bd:	e8 04 fe ff ff       	call   c01042c6 <__slob_get_free_pages>
c01044c2:	83 c4 10             	add    $0x10,%esp
c01044c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c01044c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01044cc:	75 07                	jne    c01044d5 <slob_alloc+0x196>
				return 0;
c01044ce:	b8 00 00 00 00       	mov    $0x0,%eax
c01044d3:	eb 37                	jmp    c010450c <slob_alloc+0x1cd>

			slob_free(cur, PAGE_SIZE);
c01044d5:	83 ec 08             	sub    $0x8,%esp
c01044d8:	68 00 10 00 00       	push   $0x1000
c01044dd:	ff 75 f0             	pushl  -0x10(%ebp)
c01044e0:	e8 29 00 00 00       	call   c010450e <slob_free>
c01044e5:	83 c4 10             	add    $0x10,%esp
			spin_lock_irqsave(&slob_lock, flags);
c01044e8:	e8 a4 fc ff ff       	call   c0104191 <__intr_save>
c01044ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c01044f0:	a1 08 4a 12 c0       	mov    0xc0124a08,%eax
c01044f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
	prev = slobfree;
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c01044f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01044fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01044fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104501:	8b 40 04             	mov    0x4(%eax),%eax
c0104504:	89 45 f0             	mov    %eax,-0x10(%ebp)

			slob_free(cur, PAGE_SIZE);
			spin_lock_irqsave(&slob_lock, flags);
			cur = slobfree;
		}
	}
c0104507:	e9 8f fe ff ff       	jmp    c010439b <slob_alloc+0x5c>
}
c010450c:	c9                   	leave  
c010450d:	c3                   	ret    

c010450e <slob_free>:

static void slob_free(void *block, int size)
{
c010450e:	55                   	push   %ebp
c010450f:	89 e5                	mov    %esp,%ebp
c0104511:	83 ec 18             	sub    $0x18,%esp
	slob_t *cur, *b = (slob_t *)block;
c0104514:	8b 45 08             	mov    0x8(%ebp),%eax
c0104517:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c010451a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010451e:	0f 84 05 01 00 00    	je     c0104629 <slob_free+0x11b>
		return;

	if (size)
c0104524:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104528:	74 10                	je     c010453a <slob_free+0x2c>
		b->units = SLOB_UNITS(size);
c010452a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010452d:	83 c0 07             	add    $0x7,%eax
c0104530:	c1 e8 03             	shr    $0x3,%eax
c0104533:	89 c2                	mov    %eax,%edx
c0104535:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104538:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c010453a:	e8 52 fc ff ff       	call   c0104191 <__intr_save>
c010453f:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0104542:	a1 08 4a 12 c0       	mov    0xc0124a08,%eax
c0104547:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010454a:	eb 27                	jmp    c0104573 <slob_free+0x65>
		if (cur >= cur->next && (b > cur || b < cur->next))
c010454c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010454f:	8b 40 04             	mov    0x4(%eax),%eax
c0104552:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104555:	77 13                	ja     c010456a <slob_free+0x5c>
c0104557:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010455a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010455d:	77 27                	ja     c0104586 <slob_free+0x78>
c010455f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104562:	8b 40 04             	mov    0x4(%eax),%eax
c0104565:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104568:	77 1c                	ja     c0104586 <slob_free+0x78>
	if (size)
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c010456a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010456d:	8b 40 04             	mov    0x4(%eax),%eax
c0104570:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104573:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104576:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104579:	76 d1                	jbe    c010454c <slob_free+0x3e>
c010457b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010457e:	8b 40 04             	mov    0x4(%eax),%eax
c0104581:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104584:	76 c6                	jbe    c010454c <slob_free+0x3e>
		if (cur >= cur->next && (b > cur || b < cur->next))
			break;

	if (b + b->units == cur->next) {
c0104586:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104589:	8b 00                	mov    (%eax),%eax
c010458b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104592:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104595:	01 c2                	add    %eax,%edx
c0104597:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010459a:	8b 40 04             	mov    0x4(%eax),%eax
c010459d:	39 c2                	cmp    %eax,%edx
c010459f:	75 25                	jne    c01045c6 <slob_free+0xb8>
		b->units += cur->next->units;
c01045a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045a4:	8b 10                	mov    (%eax),%edx
c01045a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045a9:	8b 40 04             	mov    0x4(%eax),%eax
c01045ac:	8b 00                	mov    (%eax),%eax
c01045ae:	01 c2                	add    %eax,%edx
c01045b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045b3:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c01045b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045b8:	8b 40 04             	mov    0x4(%eax),%eax
c01045bb:	8b 50 04             	mov    0x4(%eax),%edx
c01045be:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045c1:	89 50 04             	mov    %edx,0x4(%eax)
c01045c4:	eb 0c                	jmp    c01045d2 <slob_free+0xc4>
	} else
		b->next = cur->next;
c01045c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045c9:	8b 50 04             	mov    0x4(%eax),%edx
c01045cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045cf:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c01045d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045d5:	8b 00                	mov    (%eax),%eax
c01045d7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01045de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045e1:	01 d0                	add    %edx,%eax
c01045e3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01045e6:	75 1f                	jne    c0104607 <slob_free+0xf9>
		cur->units += b->units;
c01045e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045eb:	8b 10                	mov    (%eax),%edx
c01045ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045f0:	8b 00                	mov    (%eax),%eax
c01045f2:	01 c2                	add    %eax,%edx
c01045f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045f7:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c01045f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045fc:	8b 50 04             	mov    0x4(%eax),%edx
c01045ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104602:	89 50 04             	mov    %edx,0x4(%eax)
c0104605:	eb 09                	jmp    c0104610 <slob_free+0x102>
	} else
		cur->next = b;
c0104607:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010460a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010460d:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c0104610:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104613:	a3 08 4a 12 c0       	mov    %eax,0xc0124a08

	spin_unlock_irqrestore(&slob_lock, flags);
c0104618:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010461b:	83 ec 0c             	sub    $0xc,%esp
c010461e:	50                   	push   %eax
c010461f:	e8 97 fb ff ff       	call   c01041bb <__intr_restore>
c0104624:	83 c4 10             	add    $0x10,%esp
c0104627:	eb 01                	jmp    c010462a <slob_free+0x11c>
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
		return;
c0104629:	90                   	nop
		cur->next = b;

	slobfree = cur;

	spin_unlock_irqrestore(&slob_lock, flags);
}
c010462a:	c9                   	leave  
c010462b:	c3                   	ret    

c010462c <check_slab>:



void check_slab(void) {
c010462c:	55                   	push   %ebp
c010462d:	89 e5                	mov    %esp,%ebp
c010462f:	83 ec 08             	sub    $0x8,%esp
  cprintf("check_slab() success\n");
c0104632:	83 ec 0c             	sub    $0xc,%esp
c0104635:	68 46 a4 10 c0       	push   $0xc010a446
c010463a:	e8 4b bc ff ff       	call   c010028a <cprintf>
c010463f:	83 c4 10             	add    $0x10,%esp
}
c0104642:	90                   	nop
c0104643:	c9                   	leave  
c0104644:	c3                   	ret    

c0104645 <slab_init>:

void
slab_init(void) {
c0104645:	55                   	push   %ebp
c0104646:	89 e5                	mov    %esp,%ebp
c0104648:	83 ec 08             	sub    $0x8,%esp
  cprintf("use SLOB allocator\n");
c010464b:	83 ec 0c             	sub    $0xc,%esp
c010464e:	68 5c a4 10 c0       	push   $0xc010a45c
c0104653:	e8 32 bc ff ff       	call   c010028a <cprintf>
c0104658:	83 c4 10             	add    $0x10,%esp
  check_slab();
c010465b:	e8 cc ff ff ff       	call   c010462c <check_slab>
}
c0104660:	90                   	nop
c0104661:	c9                   	leave  
c0104662:	c3                   	ret    

c0104663 <kmalloc_init>:

inline void 
kmalloc_init(void) {
c0104663:	55                   	push   %ebp
c0104664:	89 e5                	mov    %esp,%ebp
c0104666:	83 ec 08             	sub    $0x8,%esp
    slab_init();
c0104669:	e8 d7 ff ff ff       	call   c0104645 <slab_init>
    cprintf("kmalloc_init() succeeded!\n");
c010466e:	83 ec 0c             	sub    $0xc,%esp
c0104671:	68 70 a4 10 c0       	push   $0xc010a470
c0104676:	e8 0f bc ff ff       	call   c010028a <cprintf>
c010467b:	83 c4 10             	add    $0x10,%esp
}
c010467e:	90                   	nop
c010467f:	c9                   	leave  
c0104680:	c3                   	ret    

c0104681 <slab_allocated>:

size_t
slab_allocated(void) {
c0104681:	55                   	push   %ebp
c0104682:	89 e5                	mov    %esp,%ebp
  return 0;
c0104684:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104689:	5d                   	pop    %ebp
c010468a:	c3                   	ret    

c010468b <kallocated>:

size_t
kallocated(void) {
c010468b:	55                   	push   %ebp
c010468c:	89 e5                	mov    %esp,%ebp
   return slab_allocated();
c010468e:	e8 ee ff ff ff       	call   c0104681 <slab_allocated>
}
c0104693:	5d                   	pop    %ebp
c0104694:	c3                   	ret    

c0104695 <find_order>:

static int find_order(int size)
{
c0104695:	55                   	push   %ebp
c0104696:	89 e5                	mov    %esp,%ebp
c0104698:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c010469b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c01046a2:	eb 07                	jmp    c01046ab <find_order+0x16>
		order++;
c01046a4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
}

static int find_order(int size)
{
	int order = 0;
	for ( ; size > 4096 ; size >>=1)
c01046a8:	d1 7d 08             	sarl   0x8(%ebp)
c01046ab:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c01046b2:	7f f0                	jg     c01046a4 <find_order+0xf>
		order++;
	return order;
c01046b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01046b7:	c9                   	leave  
c01046b8:	c3                   	ret    

c01046b9 <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c01046b9:	55                   	push   %ebp
c01046ba:	89 e5                	mov    %esp,%ebp
c01046bc:	83 ec 18             	sub    $0x18,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c01046bf:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c01046c6:	77 35                	ja     c01046fd <__kmalloc+0x44>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c01046c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01046cb:	83 c0 08             	add    $0x8,%eax
c01046ce:	83 ec 04             	sub    $0x4,%esp
c01046d1:	6a 00                	push   $0x0
c01046d3:	ff 75 0c             	pushl  0xc(%ebp)
c01046d6:	50                   	push   %eax
c01046d7:	e8 63 fc ff ff       	call   c010433f <slob_alloc>
c01046dc:	83 c4 10             	add    $0x10,%esp
c01046df:	89 45 f4             	mov    %eax,-0xc(%ebp)
		return m ? (void *)(m + 1) : 0;
c01046e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01046e6:	74 0b                	je     c01046f3 <__kmalloc+0x3a>
c01046e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046eb:	83 c0 08             	add    $0x8,%eax
c01046ee:	e9 b3 00 00 00       	jmp    c01047a6 <__kmalloc+0xed>
c01046f3:	b8 00 00 00 00       	mov    $0x0,%eax
c01046f8:	e9 a9 00 00 00       	jmp    c01047a6 <__kmalloc+0xed>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c01046fd:	83 ec 04             	sub    $0x4,%esp
c0104700:	6a 00                	push   $0x0
c0104702:	ff 75 0c             	pushl  0xc(%ebp)
c0104705:	6a 0c                	push   $0xc
c0104707:	e8 33 fc ff ff       	call   c010433f <slob_alloc>
c010470c:	83 c4 10             	add    $0x10,%esp
c010470f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (!bb)
c0104712:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104716:	75 0a                	jne    c0104722 <__kmalloc+0x69>
		return 0;
c0104718:	b8 00 00 00 00       	mov    $0x0,%eax
c010471d:	e9 84 00 00 00       	jmp    c01047a6 <__kmalloc+0xed>

	bb->order = find_order(size);
c0104722:	8b 45 08             	mov    0x8(%ebp),%eax
c0104725:	83 ec 0c             	sub    $0xc,%esp
c0104728:	50                   	push   %eax
c0104729:	e8 67 ff ff ff       	call   c0104695 <find_order>
c010472e:	83 c4 10             	add    $0x10,%esp
c0104731:	89 c2                	mov    %eax,%edx
c0104733:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104736:	89 10                	mov    %edx,(%eax)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0104738:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010473b:	8b 00                	mov    (%eax),%eax
c010473d:	83 ec 08             	sub    $0x8,%esp
c0104740:	50                   	push   %eax
c0104741:	ff 75 0c             	pushl  0xc(%ebp)
c0104744:	e8 7d fb ff ff       	call   c01042c6 <__slob_get_free_pages>
c0104749:	83 c4 10             	add    $0x10,%esp
c010474c:	89 c2                	mov    %eax,%edx
c010474e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104751:	89 50 04             	mov    %edx,0x4(%eax)

	if (bb->pages) {
c0104754:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104757:	8b 40 04             	mov    0x4(%eax),%eax
c010475a:	85 c0                	test   %eax,%eax
c010475c:	74 33                	je     c0104791 <__kmalloc+0xd8>
		spin_lock_irqsave(&block_lock, flags);
c010475e:	e8 2e fa ff ff       	call   c0104191 <__intr_save>
c0104763:	89 45 ec             	mov    %eax,-0x14(%ebp)
		bb->next = bigblocks;
c0104766:	8b 15 68 7f 12 c0    	mov    0xc0127f68,%edx
c010476c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010476f:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c0104772:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104775:	a3 68 7f 12 c0       	mov    %eax,0xc0127f68
		spin_unlock_irqrestore(&block_lock, flags);
c010477a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010477d:	83 ec 0c             	sub    $0xc,%esp
c0104780:	50                   	push   %eax
c0104781:	e8 35 fa ff ff       	call   c01041bb <__intr_restore>
c0104786:	83 c4 10             	add    $0x10,%esp
		return bb->pages;
c0104789:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010478c:	8b 40 04             	mov    0x4(%eax),%eax
c010478f:	eb 15                	jmp    c01047a6 <__kmalloc+0xed>
	}

	slob_free(bb, sizeof(bigblock_t));
c0104791:	83 ec 08             	sub    $0x8,%esp
c0104794:	6a 0c                	push   $0xc
c0104796:	ff 75 f0             	pushl  -0x10(%ebp)
c0104799:	e8 70 fd ff ff       	call   c010450e <slob_free>
c010479e:	83 c4 10             	add    $0x10,%esp
	return 0;
c01047a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01047a6:	c9                   	leave  
c01047a7:	c3                   	ret    

c01047a8 <kmalloc>:

void *
kmalloc(size_t size)
{
c01047a8:	55                   	push   %ebp
c01047a9:	89 e5                	mov    %esp,%ebp
c01047ab:	83 ec 08             	sub    $0x8,%esp
  return __kmalloc(size, 0);
c01047ae:	83 ec 08             	sub    $0x8,%esp
c01047b1:	6a 00                	push   $0x0
c01047b3:	ff 75 08             	pushl  0x8(%ebp)
c01047b6:	e8 fe fe ff ff       	call   c01046b9 <__kmalloc>
c01047bb:	83 c4 10             	add    $0x10,%esp
}
c01047be:	c9                   	leave  
c01047bf:	c3                   	ret    

c01047c0 <kfree>:


void kfree(void *block)
{
c01047c0:	55                   	push   %ebp
c01047c1:	89 e5                	mov    %esp,%ebp
c01047c3:	83 ec 18             	sub    $0x18,%esp
	bigblock_t *bb, **last = &bigblocks;
c01047c6:	c7 45 f0 68 7f 12 c0 	movl   $0xc0127f68,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c01047cd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01047d1:	0f 84 ac 00 00 00    	je     c0104883 <kfree+0xc3>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c01047d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01047da:	25 ff 0f 00 00       	and    $0xfff,%eax
c01047df:	85 c0                	test   %eax,%eax
c01047e1:	0f 85 85 00 00 00    	jne    c010486c <kfree+0xac>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c01047e7:	e8 a5 f9 ff ff       	call   c0104191 <__intr_save>
c01047ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c01047ef:	a1 68 7f 12 c0       	mov    0xc0127f68,%eax
c01047f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01047f7:	eb 5e                	jmp    c0104857 <kfree+0x97>
			if (bb->pages == block) {
c01047f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047fc:	8b 40 04             	mov    0x4(%eax),%eax
c01047ff:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104802:	75 41                	jne    c0104845 <kfree+0x85>
				*last = bb->next;
c0104804:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104807:	8b 50 08             	mov    0x8(%eax),%edx
c010480a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010480d:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c010480f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104812:	83 ec 0c             	sub    $0xc,%esp
c0104815:	50                   	push   %eax
c0104816:	e8 a0 f9 ff ff       	call   c01041bb <__intr_restore>
c010481b:	83 c4 10             	add    $0x10,%esp
				__slob_free_pages((unsigned long)block, bb->order);
c010481e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104821:	8b 10                	mov    (%eax),%edx
c0104823:	8b 45 08             	mov    0x8(%ebp),%eax
c0104826:	83 ec 08             	sub    $0x8,%esp
c0104829:	52                   	push   %edx
c010482a:	50                   	push   %eax
c010482b:	e8 d6 fa ff ff       	call   c0104306 <__slob_free_pages>
c0104830:	83 c4 10             	add    $0x10,%esp
				slob_free(bb, sizeof(bigblock_t));
c0104833:	83 ec 08             	sub    $0x8,%esp
c0104836:	6a 0c                	push   $0xc
c0104838:	ff 75 f4             	pushl  -0xc(%ebp)
c010483b:	e8 ce fc ff ff       	call   c010450e <slob_free>
c0104840:	83 c4 10             	add    $0x10,%esp
				return;
c0104843:	eb 3f                	jmp    c0104884 <kfree+0xc4>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104845:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104848:	83 c0 08             	add    $0x8,%eax
c010484b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010484e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104851:	8b 40 08             	mov    0x8(%eax),%eax
c0104854:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104857:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010485b:	75 9c                	jne    c01047f9 <kfree+0x39>
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
				return;
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c010485d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104860:	83 ec 0c             	sub    $0xc,%esp
c0104863:	50                   	push   %eax
c0104864:	e8 52 f9 ff ff       	call   c01041bb <__intr_restore>
c0104869:	83 c4 10             	add    $0x10,%esp
	}

	slob_free((slob_t *)block - 1, 0);
c010486c:	8b 45 08             	mov    0x8(%ebp),%eax
c010486f:	83 e8 08             	sub    $0x8,%eax
c0104872:	83 ec 08             	sub    $0x8,%esp
c0104875:	6a 00                	push   $0x0
c0104877:	50                   	push   %eax
c0104878:	e8 91 fc ff ff       	call   c010450e <slob_free>
c010487d:	83 c4 10             	add    $0x10,%esp
	return;
c0104880:	90                   	nop
c0104881:	eb 01                	jmp    c0104884 <kfree+0xc4>
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
		return;
c0104883:	90                   	nop
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
c0104884:	c9                   	leave  
c0104885:	c3                   	ret    

c0104886 <ksize>:


unsigned int ksize(const void *block)
{
c0104886:	55                   	push   %ebp
c0104887:	89 e5                	mov    %esp,%ebp
c0104889:	83 ec 18             	sub    $0x18,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c010488c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104890:	75 07                	jne    c0104899 <ksize+0x13>
		return 0;
c0104892:	b8 00 00 00 00       	mov    $0x0,%eax
c0104897:	eb 73                	jmp    c010490c <ksize+0x86>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104899:	8b 45 08             	mov    0x8(%ebp),%eax
c010489c:	25 ff 0f 00 00       	and    $0xfff,%eax
c01048a1:	85 c0                	test   %eax,%eax
c01048a3:	75 5c                	jne    c0104901 <ksize+0x7b>
		spin_lock_irqsave(&block_lock, flags);
c01048a5:	e8 e7 f8 ff ff       	call   c0104191 <__intr_save>
c01048aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c01048ad:	a1 68 7f 12 c0       	mov    0xc0127f68,%eax
c01048b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01048b5:	eb 35                	jmp    c01048ec <ksize+0x66>
			if (bb->pages == block) {
c01048b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048ba:	8b 40 04             	mov    0x4(%eax),%eax
c01048bd:	3b 45 08             	cmp    0x8(%ebp),%eax
c01048c0:	75 21                	jne    c01048e3 <ksize+0x5d>
				spin_unlock_irqrestore(&slob_lock, flags);
c01048c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048c5:	83 ec 0c             	sub    $0xc,%esp
c01048c8:	50                   	push   %eax
c01048c9:	e8 ed f8 ff ff       	call   c01041bb <__intr_restore>
c01048ce:	83 c4 10             	add    $0x10,%esp
				return PAGE_SIZE << bb->order;
c01048d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048d4:	8b 00                	mov    (%eax),%eax
c01048d6:	ba 00 10 00 00       	mov    $0x1000,%edx
c01048db:	89 c1                	mov    %eax,%ecx
c01048dd:	d3 e2                	shl    %cl,%edx
c01048df:	89 d0                	mov    %edx,%eax
c01048e1:	eb 29                	jmp    c010490c <ksize+0x86>
	if (!block)
		return 0;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; bb = bb->next)
c01048e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048e6:	8b 40 08             	mov    0x8(%eax),%eax
c01048e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01048ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01048f0:	75 c5                	jne    c01048b7 <ksize+0x31>
			if (bb->pages == block) {
				spin_unlock_irqrestore(&slob_lock, flags);
				return PAGE_SIZE << bb->order;
			}
		spin_unlock_irqrestore(&block_lock, flags);
c01048f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048f5:	83 ec 0c             	sub    $0xc,%esp
c01048f8:	50                   	push   %eax
c01048f9:	e8 bd f8 ff ff       	call   c01041bb <__intr_restore>
c01048fe:	83 c4 10             	add    $0x10,%esp
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c0104901:	8b 45 08             	mov    0x8(%ebp),%eax
c0104904:	83 e8 08             	sub    $0x8,%eax
c0104907:	8b 00                	mov    (%eax),%eax
c0104909:	c1 e0 03             	shl    $0x3,%eax
}
c010490c:	c9                   	leave  
c010490d:	c3                   	ret    

c010490e <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c010490e:	55                   	push   %ebp
c010490f:	89 e5                	mov    %esp,%ebp
c0104911:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0104914:	8b 45 08             	mov    0x8(%ebp),%eax
c0104917:	c1 e8 0c             	shr    $0xc,%eax
c010491a:	89 c2                	mov    %eax,%edx
c010491c:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0104921:	39 c2                	cmp    %eax,%edx
c0104923:	72 14                	jb     c0104939 <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0104925:	83 ec 04             	sub    $0x4,%esp
c0104928:	68 8c a4 10 c0       	push   $0xc010a48c
c010492d:	6a 5f                	push   $0x5f
c010492f:	68 ab a4 10 c0       	push   $0xc010a4ab
c0104934:	e8 b7 ba ff ff       	call   c01003f0 <__panic>
    }
    return &pages[PPN(pa)];
c0104939:	8b 0d 58 a1 12 c0    	mov    0xc012a158,%ecx
c010493f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104942:	c1 e8 0c             	shr    $0xc,%eax
c0104945:	89 c2                	mov    %eax,%edx
c0104947:	89 d0                	mov    %edx,%eax
c0104949:	c1 e0 03             	shl    $0x3,%eax
c010494c:	01 d0                	add    %edx,%eax
c010494e:	c1 e0 02             	shl    $0x2,%eax
c0104951:	01 c8                	add    %ecx,%eax
}
c0104953:	c9                   	leave  
c0104954:	c3                   	ret    

c0104955 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0104955:	55                   	push   %ebp
c0104956:	89 e5                	mov    %esp,%ebp
c0104958:	83 ec 08             	sub    $0x8,%esp
    if (!(pte & PTE_P)) {
c010495b:	8b 45 08             	mov    0x8(%ebp),%eax
c010495e:	83 e0 01             	and    $0x1,%eax
c0104961:	85 c0                	test   %eax,%eax
c0104963:	75 14                	jne    c0104979 <pte2page+0x24>
        panic("pte2page called with invalid pte");
c0104965:	83 ec 04             	sub    $0x4,%esp
c0104968:	68 bc a4 10 c0       	push   $0xc010a4bc
c010496d:	6a 71                	push   $0x71
c010496f:	68 ab a4 10 c0       	push   $0xc010a4ab
c0104974:	e8 77 ba ff ff       	call   c01003f0 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0104979:	8b 45 08             	mov    0x8(%ebp),%eax
c010497c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104981:	83 ec 0c             	sub    $0xc,%esp
c0104984:	50                   	push   %eax
c0104985:	e8 84 ff ff ff       	call   c010490e <pa2page>
c010498a:	83 c4 10             	add    $0x10,%esp
}
c010498d:	c9                   	leave  
c010498e:	c3                   	ret    

c010498f <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c010498f:	55                   	push   %ebp
c0104990:	89 e5                	mov    %esp,%ebp
c0104992:	83 ec 18             	sub    $0x18,%esp
     swapfs_init();
c0104995:	e8 cb 32 00 00       	call   c0107c65 <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c010499a:	a1 1c a1 12 c0       	mov    0xc012a11c,%eax
c010499f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c01049a4:	76 0c                	jbe    c01049b2 <swap_init+0x23>
c01049a6:	a1 1c a1 12 c0       	mov    0xc012a11c,%eax
c01049ab:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c01049b0:	76 17                	jbe    c01049c9 <swap_init+0x3a>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c01049b2:	a1 1c a1 12 c0       	mov    0xc012a11c,%eax
c01049b7:	50                   	push   %eax
c01049b8:	68 dd a4 10 c0       	push   $0xc010a4dd
c01049bd:	6a 25                	push   $0x25
c01049bf:	68 f8 a4 10 c0       	push   $0xc010a4f8
c01049c4:	e8 27 ba ff ff       	call   c01003f0 <__panic>
     }
     

     sm = &swap_manager_fifo;
c01049c9:	c7 05 74 7f 12 c0 e0 	movl   $0xc01249e0,0xc0127f74
c01049d0:	49 12 c0 
     int r = sm->init();
c01049d3:	a1 74 7f 12 c0       	mov    0xc0127f74,%eax
c01049d8:	8b 40 04             	mov    0x4(%eax),%eax
c01049db:	ff d0                	call   *%eax
c01049dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c01049e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01049e4:	75 27                	jne    c0104a0d <swap_init+0x7e>
     {
          swap_init_ok = 1;
c01049e6:	c7 05 6c 7f 12 c0 01 	movl   $0x1,0xc0127f6c
c01049ed:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c01049f0:	a1 74 7f 12 c0       	mov    0xc0127f74,%eax
c01049f5:	8b 00                	mov    (%eax),%eax
c01049f7:	83 ec 08             	sub    $0x8,%esp
c01049fa:	50                   	push   %eax
c01049fb:	68 07 a5 10 c0       	push   $0xc010a507
c0104a00:	e8 85 b8 ff ff       	call   c010028a <cprintf>
c0104a05:	83 c4 10             	add    $0x10,%esp
          check_swap();
c0104a08:	e8 f7 03 00 00       	call   c0104e04 <check_swap>
     }

     return r;
c0104a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104a10:	c9                   	leave  
c0104a11:	c3                   	ret    

c0104a12 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0104a12:	55                   	push   %ebp
c0104a13:	89 e5                	mov    %esp,%ebp
c0104a15:	83 ec 08             	sub    $0x8,%esp
     return sm->init_mm(mm);
c0104a18:	a1 74 7f 12 c0       	mov    0xc0127f74,%eax
c0104a1d:	8b 40 08             	mov    0x8(%eax),%eax
c0104a20:	83 ec 0c             	sub    $0xc,%esp
c0104a23:	ff 75 08             	pushl  0x8(%ebp)
c0104a26:	ff d0                	call   *%eax
c0104a28:	83 c4 10             	add    $0x10,%esp
}
c0104a2b:	c9                   	leave  
c0104a2c:	c3                   	ret    

c0104a2d <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c0104a2d:	55                   	push   %ebp
c0104a2e:	89 e5                	mov    %esp,%ebp
c0104a30:	83 ec 08             	sub    $0x8,%esp
     return sm->tick_event(mm);
c0104a33:	a1 74 7f 12 c0       	mov    0xc0127f74,%eax
c0104a38:	8b 40 0c             	mov    0xc(%eax),%eax
c0104a3b:	83 ec 0c             	sub    $0xc,%esp
c0104a3e:	ff 75 08             	pushl  0x8(%ebp)
c0104a41:	ff d0                	call   *%eax
c0104a43:	83 c4 10             	add    $0x10,%esp
}
c0104a46:	c9                   	leave  
c0104a47:	c3                   	ret    

c0104a48 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0104a48:	55                   	push   %ebp
c0104a49:	89 e5                	mov    %esp,%ebp
c0104a4b:	83 ec 08             	sub    $0x8,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c0104a4e:	a1 74 7f 12 c0       	mov    0xc0127f74,%eax
c0104a53:	8b 40 10             	mov    0x10(%eax),%eax
c0104a56:	ff 75 14             	pushl  0x14(%ebp)
c0104a59:	ff 75 10             	pushl  0x10(%ebp)
c0104a5c:	ff 75 0c             	pushl  0xc(%ebp)
c0104a5f:	ff 75 08             	pushl  0x8(%ebp)
c0104a62:	ff d0                	call   *%eax
c0104a64:	83 c4 10             	add    $0x10,%esp
}
c0104a67:	c9                   	leave  
c0104a68:	c3                   	ret    

c0104a69 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0104a69:	55                   	push   %ebp
c0104a6a:	89 e5                	mov    %esp,%ebp
c0104a6c:	83 ec 08             	sub    $0x8,%esp
     return sm->set_unswappable(mm, addr);
c0104a6f:	a1 74 7f 12 c0       	mov    0xc0127f74,%eax
c0104a74:	8b 40 14             	mov    0x14(%eax),%eax
c0104a77:	83 ec 08             	sub    $0x8,%esp
c0104a7a:	ff 75 0c             	pushl  0xc(%ebp)
c0104a7d:	ff 75 08             	pushl  0x8(%ebp)
c0104a80:	ff d0                	call   *%eax
c0104a82:	83 c4 10             	add    $0x10,%esp
}
c0104a85:	c9                   	leave  
c0104a86:	c3                   	ret    

c0104a87 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0104a87:	55                   	push   %ebp
c0104a88:	89 e5                	mov    %esp,%ebp
c0104a8a:	83 ec 28             	sub    $0x28,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0104a8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104a94:	e9 2e 01 00 00       	jmp    c0104bc7 <swap_out+0x140>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0104a99:	a1 74 7f 12 c0       	mov    0xc0127f74,%eax
c0104a9e:	8b 40 18             	mov    0x18(%eax),%eax
c0104aa1:	83 ec 04             	sub    $0x4,%esp
c0104aa4:	ff 75 10             	pushl  0x10(%ebp)
c0104aa7:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0104aaa:	52                   	push   %edx
c0104aab:	ff 75 08             	pushl  0x8(%ebp)
c0104aae:	ff d0                	call   *%eax
c0104ab0:	83 c4 10             	add    $0x10,%esp
c0104ab3:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0104ab6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104aba:	74 18                	je     c0104ad4 <swap_out+0x4d>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0104abc:	83 ec 08             	sub    $0x8,%esp
c0104abf:	ff 75 f4             	pushl  -0xc(%ebp)
c0104ac2:	68 1c a5 10 c0       	push   $0xc010a51c
c0104ac7:	e8 be b7 ff ff       	call   c010028a <cprintf>
c0104acc:	83 c4 10             	add    $0x10,%esp
c0104acf:	e9 ff 00 00 00       	jmp    c0104bd3 <swap_out+0x14c>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0104ad4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ad7:	8b 40 20             	mov    0x20(%eax),%eax
c0104ada:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0104add:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ae0:	8b 40 0c             	mov    0xc(%eax),%eax
c0104ae3:	83 ec 04             	sub    $0x4,%esp
c0104ae6:	6a 00                	push   $0x0
c0104ae8:	ff 75 ec             	pushl  -0x14(%ebp)
c0104aeb:	50                   	push   %eax
c0104aec:	e8 69 22 00 00       	call   c0106d5a <get_pte>
c0104af1:	83 c4 10             	add    $0x10,%esp
c0104af4:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0104af7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104afa:	8b 00                	mov    (%eax),%eax
c0104afc:	83 e0 01             	and    $0x1,%eax
c0104aff:	85 c0                	test   %eax,%eax
c0104b01:	75 16                	jne    c0104b19 <swap_out+0x92>
c0104b03:	68 49 a5 10 c0       	push   $0xc010a549
c0104b08:	68 5e a5 10 c0       	push   $0xc010a55e
c0104b0d:	6a 65                	push   $0x65
c0104b0f:	68 f8 a4 10 c0       	push   $0xc010a4f8
c0104b14:	e8 d7 b8 ff ff       	call   c01003f0 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0104b19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b1c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104b1f:	8b 52 20             	mov    0x20(%edx),%edx
c0104b22:	c1 ea 0c             	shr    $0xc,%edx
c0104b25:	83 c2 01             	add    $0x1,%edx
c0104b28:	c1 e2 08             	shl    $0x8,%edx
c0104b2b:	83 ec 08             	sub    $0x8,%esp
c0104b2e:	50                   	push   %eax
c0104b2f:	52                   	push   %edx
c0104b30:	e8 cc 31 00 00       	call   c0107d01 <swapfs_write>
c0104b35:	83 c4 10             	add    $0x10,%esp
c0104b38:	85 c0                	test   %eax,%eax
c0104b3a:	74 2b                	je     c0104b67 <swap_out+0xe0>
                    cprintf("SWAP: failed to save\n");
c0104b3c:	83 ec 0c             	sub    $0xc,%esp
c0104b3f:	68 73 a5 10 c0       	push   $0xc010a573
c0104b44:	e8 41 b7 ff ff       	call   c010028a <cprintf>
c0104b49:	83 c4 10             	add    $0x10,%esp
                    sm->map_swappable(mm, v, page, 0);
c0104b4c:	a1 74 7f 12 c0       	mov    0xc0127f74,%eax
c0104b51:	8b 40 10             	mov    0x10(%eax),%eax
c0104b54:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104b57:	6a 00                	push   $0x0
c0104b59:	52                   	push   %edx
c0104b5a:	ff 75 ec             	pushl  -0x14(%ebp)
c0104b5d:	ff 75 08             	pushl  0x8(%ebp)
c0104b60:	ff d0                	call   *%eax
c0104b62:	83 c4 10             	add    $0x10,%esp
c0104b65:	eb 5c                	jmp    c0104bc3 <swap_out+0x13c>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0104b67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b6a:	8b 40 20             	mov    0x20(%eax),%eax
c0104b6d:	c1 e8 0c             	shr    $0xc,%eax
c0104b70:	83 c0 01             	add    $0x1,%eax
c0104b73:	50                   	push   %eax
c0104b74:	ff 75 ec             	pushl  -0x14(%ebp)
c0104b77:	ff 75 f4             	pushl  -0xc(%ebp)
c0104b7a:	68 8c a5 10 c0       	push   $0xc010a58c
c0104b7f:	e8 06 b7 ff ff       	call   c010028a <cprintf>
c0104b84:	83 c4 10             	add    $0x10,%esp
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c0104b87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b8a:	8b 40 20             	mov    0x20(%eax),%eax
c0104b8d:	c1 e8 0c             	shr    $0xc,%eax
c0104b90:	83 c0 01             	add    $0x1,%eax
c0104b93:	c1 e0 08             	shl    $0x8,%eax
c0104b96:	89 c2                	mov    %eax,%edx
c0104b98:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104b9b:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0104b9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ba0:	83 ec 08             	sub    $0x8,%esp
c0104ba3:	6a 01                	push   $0x1
c0104ba5:	50                   	push   %eax
c0104ba6:	e8 9f 1b 00 00       	call   c010674a <free_pages>
c0104bab:	83 c4 10             	add    $0x10,%esp
          }
          
          tlb_invalidate(mm->pgdir, v);
c0104bae:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bb1:	8b 40 0c             	mov    0xc(%eax),%eax
c0104bb4:	83 ec 08             	sub    $0x8,%esp
c0104bb7:	ff 75 ec             	pushl  -0x14(%ebp)
c0104bba:	50                   	push   %eax
c0104bbb:	e8 64 24 00 00       	call   c0107024 <tlb_invalidate>
c0104bc0:	83 c4 10             	add    $0x10,%esp

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++ i)
c0104bc3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0104bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bca:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104bcd:	0f 85 c6 fe ff ff    	jne    c0104a99 <swap_out+0x12>
                    free_page(page);
          }
          
          tlb_invalidate(mm->pgdir, v);
     }
     return i;
c0104bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104bd6:	c9                   	leave  
c0104bd7:	c3                   	ret    

c0104bd8 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0104bd8:	55                   	push   %ebp
c0104bd9:	89 e5                	mov    %esp,%ebp
c0104bdb:	83 ec 18             	sub    $0x18,%esp
     struct Page *result = alloc_page();
c0104bde:	83 ec 0c             	sub    $0xc,%esp
c0104be1:	6a 01                	push   $0x1
c0104be3:	e8 f6 1a 00 00       	call   c01066de <alloc_pages>
c0104be8:	83 c4 10             	add    $0x10,%esp
c0104beb:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0104bee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104bf2:	75 16                	jne    c0104c0a <swap_in+0x32>
c0104bf4:	68 cc a5 10 c0       	push   $0xc010a5cc
c0104bf9:	68 5e a5 10 c0       	push   $0xc010a55e
c0104bfe:	6a 7b                	push   $0x7b
c0104c00:	68 f8 a4 10 c0       	push   $0xc010a4f8
c0104c05:	e8 e6 b7 ff ff       	call   c01003f0 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0104c0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c0d:	8b 40 0c             	mov    0xc(%eax),%eax
c0104c10:	83 ec 04             	sub    $0x4,%esp
c0104c13:	6a 00                	push   $0x0
c0104c15:	ff 75 0c             	pushl  0xc(%ebp)
c0104c18:	50                   	push   %eax
c0104c19:	e8 3c 21 00 00       	call   c0106d5a <get_pte>
c0104c1e:	83 c4 10             	add    $0x10,%esp
c0104c21:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0104c24:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c27:	8b 00                	mov    (%eax),%eax
c0104c29:	83 ec 08             	sub    $0x8,%esp
c0104c2c:	ff 75 f4             	pushl  -0xc(%ebp)
c0104c2f:	50                   	push   %eax
c0104c30:	e8 73 30 00 00       	call   c0107ca8 <swapfs_read>
c0104c35:	83 c4 10             	add    $0x10,%esp
c0104c38:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104c3b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104c3f:	74 1f                	je     c0104c60 <swap_in+0x88>
     {
        assert(r!=0);
c0104c41:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104c45:	75 19                	jne    c0104c60 <swap_in+0x88>
c0104c47:	68 d9 a5 10 c0       	push   $0xc010a5d9
c0104c4c:	68 5e a5 10 c0       	push   $0xc010a55e
c0104c51:	68 83 00 00 00       	push   $0x83
c0104c56:	68 f8 a4 10 c0       	push   $0xc010a4f8
c0104c5b:	e8 90 b7 ff ff       	call   c01003f0 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0104c60:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c63:	8b 00                	mov    (%eax),%eax
c0104c65:	c1 e8 08             	shr    $0x8,%eax
c0104c68:	83 ec 04             	sub    $0x4,%esp
c0104c6b:	ff 75 0c             	pushl  0xc(%ebp)
c0104c6e:	50                   	push   %eax
c0104c6f:	68 e0 a5 10 c0       	push   $0xc010a5e0
c0104c74:	e8 11 b6 ff ff       	call   c010028a <cprintf>
c0104c79:	83 c4 10             	add    $0x10,%esp
     *ptr_result=result;
c0104c7c:	8b 45 10             	mov    0x10(%ebp),%eax
c0104c7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104c82:	89 10                	mov    %edx,(%eax)
     return 0;
c0104c84:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104c89:	c9                   	leave  
c0104c8a:	c3                   	ret    

c0104c8b <check_content_set>:



static inline void
check_content_set(void)
{
c0104c8b:	55                   	push   %ebp
c0104c8c:	89 e5                	mov    %esp,%ebp
c0104c8e:	83 ec 08             	sub    $0x8,%esp
     *(unsigned char *)0x1000 = 0x0a;
c0104c91:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104c96:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0104c99:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0104c9e:	83 f8 01             	cmp    $0x1,%eax
c0104ca1:	74 19                	je     c0104cbc <check_content_set+0x31>
c0104ca3:	68 1e a6 10 c0       	push   $0xc010a61e
c0104ca8:	68 5e a5 10 c0       	push   $0xc010a55e
c0104cad:	68 90 00 00 00       	push   $0x90
c0104cb2:	68 f8 a4 10 c0       	push   $0xc010a4f8
c0104cb7:	e8 34 b7 ff ff       	call   c01003f0 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0104cbc:	b8 10 10 00 00       	mov    $0x1010,%eax
c0104cc1:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0104cc4:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0104cc9:	83 f8 01             	cmp    $0x1,%eax
c0104ccc:	74 19                	je     c0104ce7 <check_content_set+0x5c>
c0104cce:	68 1e a6 10 c0       	push   $0xc010a61e
c0104cd3:	68 5e a5 10 c0       	push   $0xc010a55e
c0104cd8:	68 92 00 00 00       	push   $0x92
c0104cdd:	68 f8 a4 10 c0       	push   $0xc010a4f8
c0104ce2:	e8 09 b7 ff ff       	call   c01003f0 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0104ce7:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104cec:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0104cef:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0104cf4:	83 f8 02             	cmp    $0x2,%eax
c0104cf7:	74 19                	je     c0104d12 <check_content_set+0x87>
c0104cf9:	68 2d a6 10 c0       	push   $0xc010a62d
c0104cfe:	68 5e a5 10 c0       	push   $0xc010a55e
c0104d03:	68 94 00 00 00       	push   $0x94
c0104d08:	68 f8 a4 10 c0       	push   $0xc010a4f8
c0104d0d:	e8 de b6 ff ff       	call   c01003f0 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0104d12:	b8 10 20 00 00       	mov    $0x2010,%eax
c0104d17:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0104d1a:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0104d1f:	83 f8 02             	cmp    $0x2,%eax
c0104d22:	74 19                	je     c0104d3d <check_content_set+0xb2>
c0104d24:	68 2d a6 10 c0       	push   $0xc010a62d
c0104d29:	68 5e a5 10 c0       	push   $0xc010a55e
c0104d2e:	68 96 00 00 00       	push   $0x96
c0104d33:	68 f8 a4 10 c0       	push   $0xc010a4f8
c0104d38:	e8 b3 b6 ff ff       	call   c01003f0 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0104d3d:	b8 00 30 00 00       	mov    $0x3000,%eax
c0104d42:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0104d45:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0104d4a:	83 f8 03             	cmp    $0x3,%eax
c0104d4d:	74 19                	je     c0104d68 <check_content_set+0xdd>
c0104d4f:	68 3c a6 10 c0       	push   $0xc010a63c
c0104d54:	68 5e a5 10 c0       	push   $0xc010a55e
c0104d59:	68 98 00 00 00       	push   $0x98
c0104d5e:	68 f8 a4 10 c0       	push   $0xc010a4f8
c0104d63:	e8 88 b6 ff ff       	call   c01003f0 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0104d68:	b8 10 30 00 00       	mov    $0x3010,%eax
c0104d6d:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0104d70:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0104d75:	83 f8 03             	cmp    $0x3,%eax
c0104d78:	74 19                	je     c0104d93 <check_content_set+0x108>
c0104d7a:	68 3c a6 10 c0       	push   $0xc010a63c
c0104d7f:	68 5e a5 10 c0       	push   $0xc010a55e
c0104d84:	68 9a 00 00 00       	push   $0x9a
c0104d89:	68 f8 a4 10 c0       	push   $0xc010a4f8
c0104d8e:	e8 5d b6 ff ff       	call   c01003f0 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0104d93:	b8 00 40 00 00       	mov    $0x4000,%eax
c0104d98:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0104d9b:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0104da0:	83 f8 04             	cmp    $0x4,%eax
c0104da3:	74 19                	je     c0104dbe <check_content_set+0x133>
c0104da5:	68 4b a6 10 c0       	push   $0xc010a64b
c0104daa:	68 5e a5 10 c0       	push   $0xc010a55e
c0104daf:	68 9c 00 00 00       	push   $0x9c
c0104db4:	68 f8 a4 10 c0       	push   $0xc010a4f8
c0104db9:	e8 32 b6 ff ff       	call   c01003f0 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c0104dbe:	b8 10 40 00 00       	mov    $0x4010,%eax
c0104dc3:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0104dc6:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0104dcb:	83 f8 04             	cmp    $0x4,%eax
c0104dce:	74 19                	je     c0104de9 <check_content_set+0x15e>
c0104dd0:	68 4b a6 10 c0       	push   $0xc010a64b
c0104dd5:	68 5e a5 10 c0       	push   $0xc010a55e
c0104dda:	68 9e 00 00 00       	push   $0x9e
c0104ddf:	68 f8 a4 10 c0       	push   $0xc010a4f8
c0104de4:	e8 07 b6 ff ff       	call   c01003f0 <__panic>
}
c0104de9:	90                   	nop
c0104dea:	c9                   	leave  
c0104deb:	c3                   	ret    

c0104dec <check_content_access>:

static inline int
check_content_access(void)
{
c0104dec:	55                   	push   %ebp
c0104ded:	89 e5                	mov    %esp,%ebp
c0104def:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0104df2:	a1 74 7f 12 c0       	mov    0xc0127f74,%eax
c0104df7:	8b 40 1c             	mov    0x1c(%eax),%eax
c0104dfa:	ff d0                	call   *%eax
c0104dfc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0104dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104e02:	c9                   	leave  
c0104e03:	c3                   	ret    

c0104e04 <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0104e04:	55                   	push   %ebp
c0104e05:	89 e5                	mov    %esp,%ebp
c0104e07:	83 ec 68             	sub    $0x68,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c0104e0a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104e11:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0104e18:	c7 45 e8 44 a1 12 c0 	movl   $0xc012a144,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0104e1f:	eb 60                	jmp    c0104e81 <check_swap+0x7d>
        struct Page *p = le2page(le, page_link);
c0104e21:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104e24:	83 e8 10             	sub    $0x10,%eax
c0104e27:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(PageProperty(p));
c0104e2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104e2d:	83 c0 04             	add    $0x4,%eax
c0104e30:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0104e37:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104e3a:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104e3d:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104e40:	0f a3 10             	bt     %edx,(%eax)
c0104e43:	19 c0                	sbb    %eax,%eax
c0104e45:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c0104e48:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c0104e4c:	0f 95 c0             	setne  %al
c0104e4f:	0f b6 c0             	movzbl %al,%eax
c0104e52:	85 c0                	test   %eax,%eax
c0104e54:	75 19                	jne    c0104e6f <check_swap+0x6b>
c0104e56:	68 5a a6 10 c0       	push   $0xc010a65a
c0104e5b:	68 5e a5 10 c0       	push   $0xc010a55e
c0104e60:	68 b9 00 00 00       	push   $0xb9
c0104e65:	68 f8 a4 10 c0       	push   $0xc010a4f8
c0104e6a:	e8 81 b5 ff ff       	call   c01003f0 <__panic>
        count ++, total += p->property;
c0104e6f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0104e73:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104e76:	8b 50 08             	mov    0x8(%eax),%edx
c0104e79:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e7c:	01 d0                	add    %edx,%eax
c0104e7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104e81:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104e84:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104e87:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104e8a:	8b 40 04             	mov    0x4(%eax),%eax
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c0104e8d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104e90:	81 7d e8 44 a1 12 c0 	cmpl   $0xc012a144,-0x18(%ebp)
c0104e97:	75 88                	jne    c0104e21 <check_swap+0x1d>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
     }
     assert(total == nr_free_pages());
c0104e99:	e8 e1 18 00 00       	call   c010677f <nr_free_pages>
c0104e9e:	89 c2                	mov    %eax,%edx
c0104ea0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ea3:	39 c2                	cmp    %eax,%edx
c0104ea5:	74 19                	je     c0104ec0 <check_swap+0xbc>
c0104ea7:	68 6a a6 10 c0       	push   $0xc010a66a
c0104eac:	68 5e a5 10 c0       	push   $0xc010a55e
c0104eb1:	68 bc 00 00 00       	push   $0xbc
c0104eb6:	68 f8 a4 10 c0       	push   $0xc010a4f8
c0104ebb:	e8 30 b5 ff ff       	call   c01003f0 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c0104ec0:	83 ec 04             	sub    $0x4,%esp
c0104ec3:	ff 75 f0             	pushl  -0x10(%ebp)
c0104ec6:	ff 75 f4             	pushl  -0xc(%ebp)
c0104ec9:	68 84 a6 10 c0       	push   $0xc010a684
c0104ece:	e8 b7 b3 ff ff       	call   c010028a <cprintf>
c0104ed3:	83 c4 10             	add    $0x10,%esp
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0104ed6:	e8 7f e2 ff ff       	call   c010315a <mm_create>
c0104edb:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(mm != NULL);
c0104ede:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0104ee2:	75 19                	jne    c0104efd <check_swap+0xf9>
c0104ee4:	68 aa a6 10 c0       	push   $0xc010a6aa
c0104ee9:	68 5e a5 10 c0       	push   $0xc010a55e
c0104eee:	68 c1 00 00 00       	push   $0xc1
c0104ef3:	68 f8 a4 10 c0       	push   $0xc010a4f8
c0104ef8:	e8 f3 b4 ff ff       	call   c01003f0 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0104efd:	a1 58 a0 12 c0       	mov    0xc012a058,%eax
c0104f02:	85 c0                	test   %eax,%eax
c0104f04:	74 19                	je     c0104f1f <check_swap+0x11b>
c0104f06:	68 b5 a6 10 c0       	push   $0xc010a6b5
c0104f0b:	68 5e a5 10 c0       	push   $0xc010a55e
c0104f10:	68 c4 00 00 00       	push   $0xc4
c0104f15:	68 f8 a4 10 c0       	push   $0xc010a4f8
c0104f1a:	e8 d1 b4 ff ff       	call   c01003f0 <__panic>

     check_mm_struct = mm;
c0104f1f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104f22:	a3 58 a0 12 c0       	mov    %eax,0xc012a058

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0104f27:	8b 15 20 4a 12 c0    	mov    0xc0124a20,%edx
c0104f2d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104f30:	89 50 0c             	mov    %edx,0xc(%eax)
c0104f33:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104f36:	8b 40 0c             	mov    0xc(%eax),%eax
c0104f39:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     assert(pgdir[0] == 0);
c0104f3c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104f3f:	8b 00                	mov    (%eax),%eax
c0104f41:	85 c0                	test   %eax,%eax
c0104f43:	74 19                	je     c0104f5e <check_swap+0x15a>
c0104f45:	68 cd a6 10 c0       	push   $0xc010a6cd
c0104f4a:	68 5e a5 10 c0       	push   $0xc010a55e
c0104f4f:	68 c9 00 00 00       	push   $0xc9
c0104f54:	68 f8 a4 10 c0       	push   $0xc010a4f8
c0104f59:	e8 92 b4 ff ff       	call   c01003f0 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0104f5e:	83 ec 04             	sub    $0x4,%esp
c0104f61:	6a 03                	push   $0x3
c0104f63:	68 00 60 00 00       	push   $0x6000
c0104f68:	68 00 10 00 00       	push   $0x1000
c0104f6d:	e8 64 e2 ff ff       	call   c01031d6 <vma_create>
c0104f72:	83 c4 10             	add    $0x10,%esp
c0104f75:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(vma != NULL);
c0104f78:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0104f7c:	75 19                	jne    c0104f97 <check_swap+0x193>
c0104f7e:	68 db a6 10 c0       	push   $0xc010a6db
c0104f83:	68 5e a5 10 c0       	push   $0xc010a55e
c0104f88:	68 cc 00 00 00       	push   $0xcc
c0104f8d:	68 f8 a4 10 c0       	push   $0xc010a4f8
c0104f92:	e8 59 b4 ff ff       	call   c01003f0 <__panic>

     insert_vma_struct(mm, vma);
c0104f97:	83 ec 08             	sub    $0x8,%esp
c0104f9a:	ff 75 d0             	pushl  -0x30(%ebp)
c0104f9d:	ff 75 d8             	pushl  -0x28(%ebp)
c0104fa0:	e8 99 e3 ff ff       	call   c010333e <insert_vma_struct>
c0104fa5:	83 c4 10             	add    $0x10,%esp

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0104fa8:	83 ec 0c             	sub    $0xc,%esp
c0104fab:	68 e8 a6 10 c0       	push   $0xc010a6e8
c0104fb0:	e8 d5 b2 ff ff       	call   c010028a <cprintf>
c0104fb5:	83 c4 10             	add    $0x10,%esp
     pte_t *temp_ptep=NULL;
c0104fb8:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0104fbf:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104fc2:	8b 40 0c             	mov    0xc(%eax),%eax
c0104fc5:	83 ec 04             	sub    $0x4,%esp
c0104fc8:	6a 01                	push   $0x1
c0104fca:	68 00 10 00 00       	push   $0x1000
c0104fcf:	50                   	push   %eax
c0104fd0:	e8 85 1d 00 00       	call   c0106d5a <get_pte>
c0104fd5:	83 c4 10             	add    $0x10,%esp
c0104fd8:	89 45 cc             	mov    %eax,-0x34(%ebp)
     assert(temp_ptep!= NULL);
c0104fdb:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104fdf:	75 19                	jne    c0104ffa <check_swap+0x1f6>
c0104fe1:	68 1c a7 10 c0       	push   $0xc010a71c
c0104fe6:	68 5e a5 10 c0       	push   $0xc010a55e
c0104feb:	68 d4 00 00 00       	push   $0xd4
c0104ff0:	68 f8 a4 10 c0       	push   $0xc010a4f8
c0104ff5:	e8 f6 b3 ff ff       	call   c01003f0 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0104ffa:	83 ec 0c             	sub    $0xc,%esp
c0104ffd:	68 30 a7 10 c0       	push   $0xc010a730
c0105002:	e8 83 b2 ff ff       	call   c010028a <cprintf>
c0105007:	83 c4 10             	add    $0x10,%esp
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010500a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105011:	e9 90 00 00 00       	jmp    c01050a6 <check_swap+0x2a2>
          check_rp[i] = alloc_page();
c0105016:	83 ec 0c             	sub    $0xc,%esp
c0105019:	6a 01                	push   $0x1
c010501b:	e8 be 16 00 00       	call   c01066de <alloc_pages>
c0105020:	83 c4 10             	add    $0x10,%esp
c0105023:	89 c2                	mov    %eax,%edx
c0105025:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105028:	89 14 85 80 a0 12 c0 	mov    %edx,-0x3fed5f80(,%eax,4)
          assert(check_rp[i] != NULL );
c010502f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105032:	8b 04 85 80 a0 12 c0 	mov    -0x3fed5f80(,%eax,4),%eax
c0105039:	85 c0                	test   %eax,%eax
c010503b:	75 19                	jne    c0105056 <check_swap+0x252>
c010503d:	68 54 a7 10 c0       	push   $0xc010a754
c0105042:	68 5e a5 10 c0       	push   $0xc010a55e
c0105047:	68 d9 00 00 00       	push   $0xd9
c010504c:	68 f8 a4 10 c0       	push   $0xc010a4f8
c0105051:	e8 9a b3 ff ff       	call   c01003f0 <__panic>
          assert(!PageProperty(check_rp[i]));
c0105056:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105059:	8b 04 85 80 a0 12 c0 	mov    -0x3fed5f80(,%eax,4),%eax
c0105060:	83 c0 04             	add    $0x4,%eax
c0105063:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c010506a:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010506d:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0105070:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105073:	0f a3 10             	bt     %edx,(%eax)
c0105076:	19 c0                	sbb    %eax,%eax
c0105078:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
c010507b:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
c010507f:	0f 95 c0             	setne  %al
c0105082:	0f b6 c0             	movzbl %al,%eax
c0105085:	85 c0                	test   %eax,%eax
c0105087:	74 19                	je     c01050a2 <check_swap+0x29e>
c0105089:	68 68 a7 10 c0       	push   $0xc010a768
c010508e:	68 5e a5 10 c0       	push   $0xc010a55e
c0105093:	68 da 00 00 00       	push   $0xda
c0105098:	68 f8 a4 10 c0       	push   $0xc010a4f8
c010509d:	e8 4e b3 ff ff       	call   c01003f0 <__panic>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
     assert(temp_ptep!= NULL);
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01050a2:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01050a6:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01050aa:	0f 8e 66 ff ff ff    	jle    c0105016 <check_swap+0x212>
          check_rp[i] = alloc_page();
          assert(check_rp[i] != NULL );
          assert(!PageProperty(check_rp[i]));
     }
     list_entry_t free_list_store = free_list;
c01050b0:	a1 44 a1 12 c0       	mov    0xc012a144,%eax
c01050b5:	8b 15 48 a1 12 c0    	mov    0xc012a148,%edx
c01050bb:	89 45 98             	mov    %eax,-0x68(%ebp)
c01050be:	89 55 9c             	mov    %edx,-0x64(%ebp)
c01050c1:	c7 45 c0 44 a1 12 c0 	movl   $0xc012a144,-0x40(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01050c8:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01050cb:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01050ce:	89 50 04             	mov    %edx,0x4(%eax)
c01050d1:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01050d4:	8b 50 04             	mov    0x4(%eax),%edx
c01050d7:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01050da:	89 10                	mov    %edx,(%eax)
c01050dc:	c7 45 c8 44 a1 12 c0 	movl   $0xc012a144,-0x38(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01050e3:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01050e6:	8b 40 04             	mov    0x4(%eax),%eax
c01050e9:	39 45 c8             	cmp    %eax,-0x38(%ebp)
c01050ec:	0f 94 c0             	sete   %al
c01050ef:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c01050f2:	85 c0                	test   %eax,%eax
c01050f4:	75 19                	jne    c010510f <check_swap+0x30b>
c01050f6:	68 83 a7 10 c0       	push   $0xc010a783
c01050fb:	68 5e a5 10 c0       	push   $0xc010a55e
c0105100:	68 de 00 00 00       	push   $0xde
c0105105:	68 f8 a4 10 c0       	push   $0xc010a4f8
c010510a:	e8 e1 b2 ff ff       	call   c01003f0 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c010510f:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c0105114:	89 45 bc             	mov    %eax,-0x44(%ebp)
     nr_free = 0;
c0105117:	c7 05 4c a1 12 c0 00 	movl   $0x0,0xc012a14c
c010511e:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105121:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105128:	eb 1c                	jmp    c0105146 <check_swap+0x342>
        free_pages(check_rp[i],1);
c010512a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010512d:	8b 04 85 80 a0 12 c0 	mov    -0x3fed5f80(,%eax,4),%eax
c0105134:	83 ec 08             	sub    $0x8,%esp
c0105137:	6a 01                	push   $0x1
c0105139:	50                   	push   %eax
c010513a:	e8 0b 16 00 00       	call   c010674a <free_pages>
c010513f:	83 c4 10             	add    $0x10,%esp
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105142:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0105146:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010514a:	7e de                	jle    c010512a <check_swap+0x326>
        free_pages(check_rp[i],1);
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c010514c:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c0105151:	83 f8 04             	cmp    $0x4,%eax
c0105154:	74 19                	je     c010516f <check_swap+0x36b>
c0105156:	68 9c a7 10 c0       	push   $0xc010a79c
c010515b:	68 5e a5 10 c0       	push   $0xc010a55e
c0105160:	68 e7 00 00 00       	push   $0xe7
c0105165:	68 f8 a4 10 c0       	push   $0xc010a4f8
c010516a:	e8 81 b2 ff ff       	call   c01003f0 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c010516f:	83 ec 0c             	sub    $0xc,%esp
c0105172:	68 c0 a7 10 c0       	push   $0xc010a7c0
c0105177:	e8 0e b1 ff ff       	call   c010028a <cprintf>
c010517c:	83 c4 10             	add    $0x10,%esp
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c010517f:	c7 05 64 7f 12 c0 00 	movl   $0x0,0xc0127f64
c0105186:	00 00 00 
     
     check_content_set();
c0105189:	e8 fd fa ff ff       	call   c0104c8b <check_content_set>
     assert( nr_free == 0);         
c010518e:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c0105193:	85 c0                	test   %eax,%eax
c0105195:	74 19                	je     c01051b0 <check_swap+0x3ac>
c0105197:	68 e7 a7 10 c0       	push   $0xc010a7e7
c010519c:	68 5e a5 10 c0       	push   $0xc010a55e
c01051a1:	68 f0 00 00 00       	push   $0xf0
c01051a6:	68 f8 a4 10 c0       	push   $0xc010a4f8
c01051ab:	e8 40 b2 ff ff       	call   c01003f0 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01051b0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01051b7:	eb 26                	jmp    c01051df <check_swap+0x3db>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c01051b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01051bc:	c7 04 85 a0 a0 12 c0 	movl   $0xffffffff,-0x3fed5f60(,%eax,4)
c01051c3:	ff ff ff ff 
c01051c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01051ca:	8b 14 85 a0 a0 12 c0 	mov    -0x3fed5f60(,%eax,4),%edx
c01051d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01051d4:	89 14 85 e0 a0 12 c0 	mov    %edx,-0x3fed5f20(,%eax,4)
     
     pgfault_num=0;
     
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01051db:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01051df:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c01051e3:	7e d4                	jle    c01051b9 <check_swap+0x3b5>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01051e5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01051ec:	e9 cc 00 00 00       	jmp    c01052bd <check_swap+0x4b9>
         check_ptep[i]=0;
c01051f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01051f4:	c7 04 85 34 a1 12 c0 	movl   $0x0,-0x3fed5ecc(,%eax,4)
c01051fb:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c01051ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105202:	83 c0 01             	add    $0x1,%eax
c0105205:	c1 e0 0c             	shl    $0xc,%eax
c0105208:	83 ec 04             	sub    $0x4,%esp
c010520b:	6a 00                	push   $0x0
c010520d:	50                   	push   %eax
c010520e:	ff 75 d4             	pushl  -0x2c(%ebp)
c0105211:	e8 44 1b 00 00       	call   c0106d5a <get_pte>
c0105216:	83 c4 10             	add    $0x10,%esp
c0105219:	89 c2                	mov    %eax,%edx
c010521b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010521e:	89 14 85 34 a1 12 c0 	mov    %edx,-0x3fed5ecc(,%eax,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0105225:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105228:	8b 04 85 34 a1 12 c0 	mov    -0x3fed5ecc(,%eax,4),%eax
c010522f:	85 c0                	test   %eax,%eax
c0105231:	75 19                	jne    c010524c <check_swap+0x448>
c0105233:	68 f4 a7 10 c0       	push   $0xc010a7f4
c0105238:	68 5e a5 10 c0       	push   $0xc010a55e
c010523d:	68 f8 00 00 00       	push   $0xf8
c0105242:	68 f8 a4 10 c0       	push   $0xc010a4f8
c0105247:	e8 a4 b1 ff ff       	call   c01003f0 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c010524c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010524f:	8b 04 85 34 a1 12 c0 	mov    -0x3fed5ecc(,%eax,4),%eax
c0105256:	8b 00                	mov    (%eax),%eax
c0105258:	83 ec 0c             	sub    $0xc,%esp
c010525b:	50                   	push   %eax
c010525c:	e8 f4 f6 ff ff       	call   c0104955 <pte2page>
c0105261:	83 c4 10             	add    $0x10,%esp
c0105264:	89 c2                	mov    %eax,%edx
c0105266:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105269:	8b 04 85 80 a0 12 c0 	mov    -0x3fed5f80(,%eax,4),%eax
c0105270:	39 c2                	cmp    %eax,%edx
c0105272:	74 19                	je     c010528d <check_swap+0x489>
c0105274:	68 0c a8 10 c0       	push   $0xc010a80c
c0105279:	68 5e a5 10 c0       	push   $0xc010a55e
c010527e:	68 f9 00 00 00       	push   $0xf9
c0105283:	68 f8 a4 10 c0       	push   $0xc010a4f8
c0105288:	e8 63 b1 ff ff       	call   c01003f0 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c010528d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105290:	8b 04 85 34 a1 12 c0 	mov    -0x3fed5ecc(,%eax,4),%eax
c0105297:	8b 00                	mov    (%eax),%eax
c0105299:	83 e0 01             	and    $0x1,%eax
c010529c:	85 c0                	test   %eax,%eax
c010529e:	75 19                	jne    c01052b9 <check_swap+0x4b5>
c01052a0:	68 34 a8 10 c0       	push   $0xc010a834
c01052a5:	68 5e a5 10 c0       	push   $0xc010a55e
c01052aa:	68 fa 00 00 00       	push   $0xfa
c01052af:	68 f8 a4 10 c0       	push   $0xc010a4f8
c01052b4:	e8 37 b1 ff ff       	call   c01003f0 <__panic>
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01052b9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01052bd:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01052c1:	0f 8e 2a ff ff ff    	jle    c01051f1 <check_swap+0x3ed>
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
         assert((*check_ptep[i] & PTE_P));          
     }
     cprintf("set up init env for check_swap over!\n");
c01052c7:	83 ec 0c             	sub    $0xc,%esp
c01052ca:	68 50 a8 10 c0       	push   $0xc010a850
c01052cf:	e8 b6 af ff ff       	call   c010028a <cprintf>
c01052d4:	83 c4 10             	add    $0x10,%esp
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c01052d7:	e8 10 fb ff ff       	call   c0104dec <check_content_access>
c01052dc:	89 45 b8             	mov    %eax,-0x48(%ebp)
     assert(ret==0);
c01052df:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01052e3:	74 19                	je     c01052fe <check_swap+0x4fa>
c01052e5:	68 76 a8 10 c0       	push   $0xc010a876
c01052ea:	68 5e a5 10 c0       	push   $0xc010a55e
c01052ef:	68 ff 00 00 00       	push   $0xff
c01052f4:	68 f8 a4 10 c0       	push   $0xc010a4f8
c01052f9:	e8 f2 b0 ff ff       	call   c01003f0 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01052fe:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105305:	eb 1c                	jmp    c0105323 <check_swap+0x51f>
         free_pages(check_rp[i],1);
c0105307:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010530a:	8b 04 85 80 a0 12 c0 	mov    -0x3fed5f80(,%eax,4),%eax
c0105311:	83 ec 08             	sub    $0x8,%esp
c0105314:	6a 01                	push   $0x1
c0105316:	50                   	push   %eax
c0105317:	e8 2e 14 00 00       	call   c010674a <free_pages>
c010531c:	83 c4 10             	add    $0x10,%esp
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010531f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0105323:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0105327:	7e de                	jle    c0105307 <check_swap+0x503>
         free_pages(check_rp[i],1);
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c0105329:	83 ec 0c             	sub    $0xc,%esp
c010532c:	ff 75 d8             	pushl  -0x28(%ebp)
c010532f:	e8 2e e1 ff ff       	call   c0103462 <mm_destroy>
c0105334:	83 c4 10             	add    $0x10,%esp
         
     nr_free = nr_free_store;
c0105337:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010533a:	a3 4c a1 12 c0       	mov    %eax,0xc012a14c
     free_list = free_list_store;
c010533f:	8b 45 98             	mov    -0x68(%ebp),%eax
c0105342:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0105345:	a3 44 a1 12 c0       	mov    %eax,0xc012a144
c010534a:	89 15 48 a1 12 c0    	mov    %edx,0xc012a148

     
     le = &free_list;
c0105350:	c7 45 e8 44 a1 12 c0 	movl   $0xc012a144,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0105357:	eb 1d                	jmp    c0105376 <check_swap+0x572>
         struct Page *p = le2page(le, page_link);
c0105359:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010535c:	83 e8 10             	sub    $0x10,%eax
c010535f:	89 45 b4             	mov    %eax,-0x4c(%ebp)
         count --, total -= p->property;
c0105362:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0105366:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105369:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010536c:	8b 40 08             	mov    0x8(%eax),%eax
c010536f:	29 c2                	sub    %eax,%edx
c0105371:	89 d0                	mov    %edx,%eax
c0105373:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105376:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105379:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010537c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010537f:	8b 40 04             	mov    0x4(%eax),%eax
     nr_free = nr_free_store;
     free_list = free_list_store;

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c0105382:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105385:	81 7d e8 44 a1 12 c0 	cmpl   $0xc012a144,-0x18(%ebp)
c010538c:	75 cb                	jne    c0105359 <check_swap+0x555>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
     }
     cprintf("count is %d, total is %d\n",count,total);
c010538e:	83 ec 04             	sub    $0x4,%esp
c0105391:	ff 75 f0             	pushl  -0x10(%ebp)
c0105394:	ff 75 f4             	pushl  -0xc(%ebp)
c0105397:	68 7d a8 10 c0       	push   $0xc010a87d
c010539c:	e8 e9 ae ff ff       	call   c010028a <cprintf>
c01053a1:	83 c4 10             	add    $0x10,%esp
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c01053a4:	83 ec 0c             	sub    $0xc,%esp
c01053a7:	68 97 a8 10 c0       	push   $0xc010a897
c01053ac:	e8 d9 ae ff ff       	call   c010028a <cprintf>
c01053b1:	83 c4 10             	add    $0x10,%esp
}
c01053b4:	90                   	nop
c01053b5:	c9                   	leave  
c01053b6:	c3                   	ret    

c01053b7 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01053b7:	55                   	push   %ebp
c01053b8:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01053ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01053bd:	8b 15 58 a1 12 c0    	mov    0xc012a158,%edx
c01053c3:	29 d0                	sub    %edx,%eax
c01053c5:	c1 f8 02             	sar    $0x2,%eax
c01053c8:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c01053ce:	5d                   	pop    %ebp
c01053cf:	c3                   	ret    

c01053d0 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01053d0:	55                   	push   %ebp
c01053d1:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c01053d3:	ff 75 08             	pushl  0x8(%ebp)
c01053d6:	e8 dc ff ff ff       	call   c01053b7 <page2ppn>
c01053db:	83 c4 04             	add    $0x4,%esp
c01053de:	c1 e0 0c             	shl    $0xc,%eax
}
c01053e1:	c9                   	leave  
c01053e2:	c3                   	ret    

c01053e3 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c01053e3:	55                   	push   %ebp
c01053e4:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01053e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01053e9:	8b 00                	mov    (%eax),%eax
}
c01053eb:	5d                   	pop    %ebp
c01053ec:	c3                   	ret    

c01053ed <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01053ed:	55                   	push   %ebp
c01053ee:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01053f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01053f3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01053f6:	89 10                	mov    %edx,(%eax)
}
c01053f8:	90                   	nop
c01053f9:	5d                   	pop    %ebp
c01053fa:	c3                   	ret    

c01053fb <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c01053fb:	55                   	push   %ebp
c01053fc:	89 e5                	mov    %esp,%ebp
c01053fe:	83 ec 10             	sub    $0x10,%esp
c0105401:	c7 45 fc 44 a1 12 c0 	movl   $0xc012a144,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0105408:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010540b:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010540e:	89 50 04             	mov    %edx,0x4(%eax)
c0105411:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105414:	8b 50 04             	mov    0x4(%eax),%edx
c0105417:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010541a:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c010541c:	c7 05 4c a1 12 c0 00 	movl   $0x0,0xc012a14c
c0105423:	00 00 00 
}
c0105426:	90                   	nop
c0105427:	c9                   	leave  
c0105428:	c3                   	ret    

c0105429 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0105429:	55                   	push   %ebp
c010542a:	89 e5                	mov    %esp,%ebp
c010542c:	83 ec 38             	sub    $0x38,%esp
    assert(n > 0);
c010542f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105433:	75 16                	jne    c010544b <default_init_memmap+0x22>
c0105435:	68 b0 a8 10 c0       	push   $0xc010a8b0
c010543a:	68 b6 a8 10 c0       	push   $0xc010a8b6
c010543f:	6a 6d                	push   $0x6d
c0105441:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105446:	e8 a5 af ff ff       	call   c01003f0 <__panic>
    struct Page *p = base;
c010544b:	8b 45 08             	mov    0x8(%ebp),%eax
c010544e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0105451:	eb 6c                	jmp    c01054bf <default_init_memmap+0x96>
        assert(PageReserved(p));
c0105453:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105456:	83 c0 04             	add    $0x4,%eax
c0105459:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0105460:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105463:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105466:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105469:	0f a3 10             	bt     %edx,(%eax)
c010546c:	19 c0                	sbb    %eax,%eax
c010546e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
c0105471:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105475:	0f 95 c0             	setne  %al
c0105478:	0f b6 c0             	movzbl %al,%eax
c010547b:	85 c0                	test   %eax,%eax
c010547d:	75 16                	jne    c0105495 <default_init_memmap+0x6c>
c010547f:	68 e1 a8 10 c0       	push   $0xc010a8e1
c0105484:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105489:	6a 70                	push   $0x70
c010548b:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105490:	e8 5b af ff ff       	call   c01003f0 <__panic>
        p->flags = p->property = 0;
c0105495:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105498:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c010549f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054a2:	8b 50 08             	mov    0x8(%eax),%edx
c01054a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054a8:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c01054ab:	83 ec 08             	sub    $0x8,%esp
c01054ae:	6a 00                	push   $0x0
c01054b0:	ff 75 f4             	pushl  -0xc(%ebp)
c01054b3:	e8 35 ff ff ff       	call   c01053ed <set_page_ref>
c01054b8:	83 c4 10             	add    $0x10,%esp

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c01054bb:	83 45 f4 24          	addl   $0x24,-0xc(%ebp)
c01054bf:	8b 55 0c             	mov    0xc(%ebp),%edx
c01054c2:	89 d0                	mov    %edx,%eax
c01054c4:	c1 e0 03             	shl    $0x3,%eax
c01054c7:	01 d0                	add    %edx,%eax
c01054c9:	c1 e0 02             	shl    $0x2,%eax
c01054cc:	89 c2                	mov    %eax,%edx
c01054ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01054d1:	01 d0                	add    %edx,%eax
c01054d3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01054d6:	0f 85 77 ff ff ff    	jne    c0105453 <default_init_memmap+0x2a>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c01054dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01054df:	8b 55 0c             	mov    0xc(%ebp),%edx
c01054e2:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c01054e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01054e8:	83 c0 04             	add    $0x4,%eax
c01054eb:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c01054f2:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01054f5:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01054f8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01054fb:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c01054fe:	8b 15 4c a1 12 c0    	mov    0xc012a14c,%edx
c0105504:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105507:	01 d0                	add    %edx,%eax
c0105509:	a3 4c a1 12 c0       	mov    %eax,0xc012a14c
    list_add_before(&free_list, &(base->page_link));
c010550e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105511:	83 c0 10             	add    $0x10,%eax
c0105514:	c7 45 f0 44 a1 12 c0 	movl   $0xc012a144,-0x10(%ebp)
c010551b:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c010551e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105521:	8b 00                	mov    (%eax),%eax
c0105523:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105526:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0105529:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010552c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010552f:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0105532:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105535:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105538:	89 10                	mov    %edx,(%eax)
c010553a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010553d:	8b 10                	mov    (%eax),%edx
c010553f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105542:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0105545:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105548:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010554b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010554e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105551:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105554:	89 10                	mov    %edx,(%eax)
}
c0105556:	90                   	nop
c0105557:	c9                   	leave  
c0105558:	c3                   	ret    

c0105559 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0105559:	55                   	push   %ebp
c010555a:	89 e5                	mov    %esp,%ebp
c010555c:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c010555f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105563:	75 16                	jne    c010557b <default_alloc_pages+0x22>
c0105565:	68 b0 a8 10 c0       	push   $0xc010a8b0
c010556a:	68 b6 a8 10 c0       	push   $0xc010a8b6
c010556f:	6a 7c                	push   $0x7c
c0105571:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105576:	e8 75 ae ff ff       	call   c01003f0 <__panic>
    if (n > nr_free) {
c010557b:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c0105580:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105583:	73 0a                	jae    c010558f <default_alloc_pages+0x36>
        return NULL;
c0105585:	b8 00 00 00 00       	mov    $0x0,%eax
c010558a:	e9 3d 01 00 00       	jmp    c01056cc <default_alloc_pages+0x173>
    }
    struct Page *page = NULL;
c010558f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0105596:	c7 45 f0 44 a1 12 c0 	movl   $0xc012a144,-0x10(%ebp)
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c010559d:	eb 1c                	jmp    c01055bb <default_alloc_pages+0x62>
        struct Page *p = le2page(le, page_link);
c010559f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01055a2:	83 e8 10             	sub    $0x10,%eax
c01055a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (p->property >= n) {
c01055a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01055ab:	8b 40 08             	mov    0x8(%eax),%eax
c01055ae:	3b 45 08             	cmp    0x8(%ebp),%eax
c01055b1:	72 08                	jb     c01055bb <default_alloc_pages+0x62>
            page = p;
c01055b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01055b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c01055b9:	eb 18                	jmp    c01055d3 <default_alloc_pages+0x7a>
c01055bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01055be:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01055c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01055c4:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c01055c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01055ca:	81 7d f0 44 a1 12 c0 	cmpl   $0xc012a144,-0x10(%ebp)
c01055d1:	75 cc                	jne    c010559f <default_alloc_pages+0x46>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
c01055d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01055d7:	0f 84 ec 00 00 00    	je     c01056c9 <default_alloc_pages+0x170>
        if (page->property > n) {
c01055dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055e0:	8b 40 08             	mov    0x8(%eax),%eax
c01055e3:	3b 45 08             	cmp    0x8(%ebp),%eax
c01055e6:	0f 86 8c 00 00 00    	jbe    c0105678 <default_alloc_pages+0x11f>
            struct Page *p = page + n;
c01055ec:	8b 55 08             	mov    0x8(%ebp),%edx
c01055ef:	89 d0                	mov    %edx,%eax
c01055f1:	c1 e0 03             	shl    $0x3,%eax
c01055f4:	01 d0                	add    %edx,%eax
c01055f6:	c1 e0 02             	shl    $0x2,%eax
c01055f9:	89 c2                	mov    %eax,%edx
c01055fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055fe:	01 d0                	add    %edx,%eax
c0105600:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            p->property = page->property - n;
c0105603:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105606:	8b 40 08             	mov    0x8(%eax),%eax
c0105609:	2b 45 08             	sub    0x8(%ebp),%eax
c010560c:	89 c2                	mov    %eax,%edx
c010560e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105611:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c0105614:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105617:	83 c0 04             	add    $0x4,%eax
c010561a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
c0105621:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0105624:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105627:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010562a:	0f ab 10             	bts    %edx,(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
c010562d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105630:	83 c0 10             	add    $0x10,%eax
c0105633:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105636:	83 c2 10             	add    $0x10,%edx
c0105639:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010563c:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c010563f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105642:	8b 40 04             	mov    0x4(%eax),%eax
c0105645:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105648:	89 55 cc             	mov    %edx,-0x34(%ebp)
c010564b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010564e:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0105651:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0105654:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105657:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010565a:	89 10                	mov    %edx,(%eax)
c010565c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010565f:	8b 10                	mov    (%eax),%edx
c0105661:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105664:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0105667:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010566a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010566d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0105670:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105673:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105676:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
c0105678:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010567b:	83 c0 10             	add    $0x10,%eax
c010567e:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0105681:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105684:	8b 40 04             	mov    0x4(%eax),%eax
c0105687:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010568a:	8b 12                	mov    (%edx),%edx
c010568c:	89 55 b8             	mov    %edx,-0x48(%ebp)
c010568f:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0105692:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105695:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0105698:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010569b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010569e:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01056a1:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c01056a3:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c01056a8:	2b 45 08             	sub    0x8(%ebp),%eax
c01056ab:	a3 4c a1 12 c0       	mov    %eax,0xc012a14c
        ClearPageProperty(page);
c01056b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056b3:	83 c0 04             	add    $0x4,%eax
c01056b6:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01056bd:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01056c0:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01056c3:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01056c6:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c01056c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01056cc:	c9                   	leave  
c01056cd:	c3                   	ret    

c01056ce <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c01056ce:	55                   	push   %ebp
c01056cf:	89 e5                	mov    %esp,%ebp
c01056d1:	81 ec 88 00 00 00    	sub    $0x88,%esp
    assert(n > 0);
c01056d7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01056db:	75 19                	jne    c01056f6 <default_free_pages+0x28>
c01056dd:	68 b0 a8 10 c0       	push   $0xc010a8b0
c01056e2:	68 b6 a8 10 c0       	push   $0xc010a8b6
c01056e7:	68 9a 00 00 00       	push   $0x9a
c01056ec:	68 cb a8 10 c0       	push   $0xc010a8cb
c01056f1:	e8 fa ac ff ff       	call   c01003f0 <__panic>
    struct Page *p = base;
c01056f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01056f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01056fc:	e9 8f 00 00 00       	jmp    c0105790 <default_free_pages+0xc2>
        assert(!PageReserved(p) && !PageProperty(p));
c0105701:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105704:	83 c0 04             	add    $0x4,%eax
c0105707:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
c010570e:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105711:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105714:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0105717:	0f a3 10             	bt     %edx,(%eax)
c010571a:	19 c0                	sbb    %eax,%eax
c010571c:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c010571f:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0105723:	0f 95 c0             	setne  %al
c0105726:	0f b6 c0             	movzbl %al,%eax
c0105729:	85 c0                	test   %eax,%eax
c010572b:	75 2c                	jne    c0105759 <default_free_pages+0x8b>
c010572d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105730:	83 c0 04             	add    $0x4,%eax
c0105733:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c010573a:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010573d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105740:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105743:	0f a3 10             	bt     %edx,(%eax)
c0105746:	19 c0                	sbb    %eax,%eax
c0105748:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return oldbit != 0;
c010574b:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
c010574f:	0f 95 c0             	setne  %al
c0105752:	0f b6 c0             	movzbl %al,%eax
c0105755:	85 c0                	test   %eax,%eax
c0105757:	74 19                	je     c0105772 <default_free_pages+0xa4>
c0105759:	68 f4 a8 10 c0       	push   $0xc010a8f4
c010575e:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105763:	68 9d 00 00 00       	push   $0x9d
c0105768:	68 cb a8 10 c0       	push   $0xc010a8cb
c010576d:	e8 7e ac ff ff       	call   c01003f0 <__panic>
        p->flags = 0;
c0105772:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105775:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c010577c:	83 ec 08             	sub    $0x8,%esp
c010577f:	6a 00                	push   $0x0
c0105781:	ff 75 f4             	pushl  -0xc(%ebp)
c0105784:	e8 64 fc ff ff       	call   c01053ed <set_page_ref>
c0105789:	83 c4 10             	add    $0x10,%esp

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c010578c:	83 45 f4 24          	addl   $0x24,-0xc(%ebp)
c0105790:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105793:	89 d0                	mov    %edx,%eax
c0105795:	c1 e0 03             	shl    $0x3,%eax
c0105798:	01 d0                	add    %edx,%eax
c010579a:	c1 e0 02             	shl    $0x2,%eax
c010579d:	89 c2                	mov    %eax,%edx
c010579f:	8b 45 08             	mov    0x8(%ebp),%eax
c01057a2:	01 d0                	add    %edx,%eax
c01057a4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01057a7:	0f 85 54 ff ff ff    	jne    c0105701 <default_free_pages+0x33>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c01057ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01057b0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01057b3:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c01057b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01057b9:	83 c0 04             	add    $0x4,%eax
c01057bc:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01057c3:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01057c6:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01057c9:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01057cc:	0f ab 10             	bts    %edx,(%eax)
c01057cf:	c7 45 e8 44 a1 12 c0 	movl   $0xc012a144,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01057d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01057d9:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c01057dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c01057df:	e9 08 01 00 00       	jmp    c01058ec <default_free_pages+0x21e>
        p = le2page(le, page_link);
c01057e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057e7:	83 e8 10             	sub    $0x10,%eax
c01057ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01057ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01057f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01057f6:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c01057f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
c01057fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01057ff:	8b 50 08             	mov    0x8(%eax),%edx
c0105802:	89 d0                	mov    %edx,%eax
c0105804:	c1 e0 03             	shl    $0x3,%eax
c0105807:	01 d0                	add    %edx,%eax
c0105809:	c1 e0 02             	shl    $0x2,%eax
c010580c:	89 c2                	mov    %eax,%edx
c010580e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105811:	01 d0                	add    %edx,%eax
c0105813:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105816:	75 5a                	jne    c0105872 <default_free_pages+0x1a4>
            base->property += p->property;
c0105818:	8b 45 08             	mov    0x8(%ebp),%eax
c010581b:	8b 50 08             	mov    0x8(%eax),%edx
c010581e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105821:	8b 40 08             	mov    0x8(%eax),%eax
c0105824:	01 c2                	add    %eax,%edx
c0105826:	8b 45 08             	mov    0x8(%ebp),%eax
c0105829:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c010582c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010582f:	83 c0 04             	add    $0x4,%eax
c0105832:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0105839:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010583c:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010583f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105842:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c0105845:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105848:	83 c0 10             	add    $0x10,%eax
c010584b:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c010584e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105851:	8b 40 04             	mov    0x4(%eax),%eax
c0105854:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105857:	8b 12                	mov    (%edx),%edx
c0105859:	89 55 a8             	mov    %edx,-0x58(%ebp)
c010585c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010585f:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105862:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0105865:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0105868:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010586b:	8b 55 a8             	mov    -0x58(%ebp),%edx
c010586e:	89 10                	mov    %edx,(%eax)
c0105870:	eb 7a                	jmp    c01058ec <default_free_pages+0x21e>
        }
        else if (p + p->property == base) {
c0105872:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105875:	8b 50 08             	mov    0x8(%eax),%edx
c0105878:	89 d0                	mov    %edx,%eax
c010587a:	c1 e0 03             	shl    $0x3,%eax
c010587d:	01 d0                	add    %edx,%eax
c010587f:	c1 e0 02             	shl    $0x2,%eax
c0105882:	89 c2                	mov    %eax,%edx
c0105884:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105887:	01 d0                	add    %edx,%eax
c0105889:	3b 45 08             	cmp    0x8(%ebp),%eax
c010588c:	75 5e                	jne    c01058ec <default_free_pages+0x21e>
            p->property += base->property;
c010588e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105891:	8b 50 08             	mov    0x8(%eax),%edx
c0105894:	8b 45 08             	mov    0x8(%ebp),%eax
c0105897:	8b 40 08             	mov    0x8(%eax),%eax
c010589a:	01 c2                	add    %eax,%edx
c010589c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010589f:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c01058a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01058a5:	83 c0 04             	add    $0x4,%eax
c01058a8:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c01058af:	89 45 94             	mov    %eax,-0x6c(%ebp)
c01058b2:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01058b5:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01058b8:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c01058bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058be:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c01058c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058c4:	83 c0 10             	add    $0x10,%eax
c01058c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01058ca:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01058cd:	8b 40 04             	mov    0x4(%eax),%eax
c01058d0:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01058d3:	8b 12                	mov    (%edx),%edx
c01058d5:	89 55 9c             	mov    %edx,-0x64(%ebp)
c01058d8:	89 45 98             	mov    %eax,-0x68(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01058db:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01058de:	8b 55 98             	mov    -0x68(%ebp),%edx
c01058e1:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01058e4:	8b 45 98             	mov    -0x68(%ebp),%eax
c01058e7:	8b 55 9c             	mov    -0x64(%ebp),%edx
c01058ea:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
c01058ec:	81 7d f0 44 a1 12 c0 	cmpl   $0xc012a144,-0x10(%ebp)
c01058f3:	0f 85 eb fe ff ff    	jne    c01057e4 <default_free_pages+0x116>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c01058f9:	8b 15 4c a1 12 c0    	mov    0xc012a14c,%edx
c01058ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105902:	01 d0                	add    %edx,%eax
c0105904:	a3 4c a1 12 c0       	mov    %eax,0xc012a14c
c0105909:	c7 45 d0 44 a1 12 c0 	movl   $0xc012a144,-0x30(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0105910:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105913:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c0105916:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0105919:	eb 69                	jmp    c0105984 <default_free_pages+0x2b6>
        p = le2page(le, page_link);
c010591b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010591e:	83 e8 10             	sub    $0x10,%eax
c0105921:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c0105924:	8b 45 08             	mov    0x8(%ebp),%eax
c0105927:	8b 50 08             	mov    0x8(%eax),%edx
c010592a:	89 d0                	mov    %edx,%eax
c010592c:	c1 e0 03             	shl    $0x3,%eax
c010592f:	01 d0                	add    %edx,%eax
c0105931:	c1 e0 02             	shl    $0x2,%eax
c0105934:	89 c2                	mov    %eax,%edx
c0105936:	8b 45 08             	mov    0x8(%ebp),%eax
c0105939:	01 d0                	add    %edx,%eax
c010593b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010593e:	77 35                	ja     c0105975 <default_free_pages+0x2a7>
            assert(base + base->property != p);
c0105940:	8b 45 08             	mov    0x8(%ebp),%eax
c0105943:	8b 50 08             	mov    0x8(%eax),%edx
c0105946:	89 d0                	mov    %edx,%eax
c0105948:	c1 e0 03             	shl    $0x3,%eax
c010594b:	01 d0                	add    %edx,%eax
c010594d:	c1 e0 02             	shl    $0x2,%eax
c0105950:	89 c2                	mov    %eax,%edx
c0105952:	8b 45 08             	mov    0x8(%ebp),%eax
c0105955:	01 d0                	add    %edx,%eax
c0105957:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010595a:	75 33                	jne    c010598f <default_free_pages+0x2c1>
c010595c:	68 19 a9 10 c0       	push   $0xc010a919
c0105961:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105966:	68 b9 00 00 00       	push   $0xb9
c010596b:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105970:	e8 7b aa ff ff       	call   c01003f0 <__panic>
c0105975:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105978:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010597b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010597e:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
c0105981:	89 45 f0             	mov    %eax,-0x10(%ebp)
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) {
c0105984:	81 7d f0 44 a1 12 c0 	cmpl   $0xc012a144,-0x10(%ebp)
c010598b:	75 8e                	jne    c010591b <default_free_pages+0x24d>
c010598d:	eb 01                	jmp    c0105990 <default_free_pages+0x2c2>
        p = le2page(le, page_link);
        if (base + base->property <= p) {
            assert(base + base->property != p);
            break;
c010598f:	90                   	nop
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
c0105990:	8b 45 08             	mov    0x8(%ebp),%eax
c0105993:	8d 50 10             	lea    0x10(%eax),%edx
c0105996:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105999:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010599c:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c010599f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01059a2:	8b 00                	mov    (%eax),%eax
c01059a4:	8b 55 90             	mov    -0x70(%ebp),%edx
c01059a7:	89 55 8c             	mov    %edx,-0x74(%ebp)
c01059aa:	89 45 88             	mov    %eax,-0x78(%ebp)
c01059ad:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01059b0:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01059b3:	8b 45 84             	mov    -0x7c(%ebp),%eax
c01059b6:	8b 55 8c             	mov    -0x74(%ebp),%edx
c01059b9:	89 10                	mov    %edx,(%eax)
c01059bb:	8b 45 84             	mov    -0x7c(%ebp),%eax
c01059be:	8b 10                	mov    (%eax),%edx
c01059c0:	8b 45 88             	mov    -0x78(%ebp),%eax
c01059c3:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01059c6:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01059c9:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01059cc:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01059cf:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01059d2:	8b 55 88             	mov    -0x78(%ebp),%edx
c01059d5:	89 10                	mov    %edx,(%eax)
}
c01059d7:	90                   	nop
c01059d8:	c9                   	leave  
c01059d9:	c3                   	ret    

c01059da <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c01059da:	55                   	push   %ebp
c01059db:	89 e5                	mov    %esp,%ebp
    return nr_free;
c01059dd:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
}
c01059e2:	5d                   	pop    %ebp
c01059e3:	c3                   	ret    

c01059e4 <basic_check>:

static void
basic_check(void) {
c01059e4:	55                   	push   %ebp
c01059e5:	89 e5                	mov    %esp,%ebp
c01059e7:	83 ec 38             	sub    $0x38,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c01059ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01059f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01059f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c01059fd:	83 ec 0c             	sub    $0xc,%esp
c0105a00:	6a 01                	push   $0x1
c0105a02:	e8 d7 0c 00 00       	call   c01066de <alloc_pages>
c0105a07:	83 c4 10             	add    $0x10,%esp
c0105a0a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105a0d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105a11:	75 19                	jne    c0105a2c <basic_check+0x48>
c0105a13:	68 34 a9 10 c0       	push   $0xc010a934
c0105a18:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105a1d:	68 ca 00 00 00       	push   $0xca
c0105a22:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105a27:	e8 c4 a9 ff ff       	call   c01003f0 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0105a2c:	83 ec 0c             	sub    $0xc,%esp
c0105a2f:	6a 01                	push   $0x1
c0105a31:	e8 a8 0c 00 00       	call   c01066de <alloc_pages>
c0105a36:	83 c4 10             	add    $0x10,%esp
c0105a39:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a3c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105a40:	75 19                	jne    c0105a5b <basic_check+0x77>
c0105a42:	68 50 a9 10 c0       	push   $0xc010a950
c0105a47:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105a4c:	68 cb 00 00 00       	push   $0xcb
c0105a51:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105a56:	e8 95 a9 ff ff       	call   c01003f0 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0105a5b:	83 ec 0c             	sub    $0xc,%esp
c0105a5e:	6a 01                	push   $0x1
c0105a60:	e8 79 0c 00 00       	call   c01066de <alloc_pages>
c0105a65:	83 c4 10             	add    $0x10,%esp
c0105a68:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105a6b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105a6f:	75 19                	jne    c0105a8a <basic_check+0xa6>
c0105a71:	68 6c a9 10 c0       	push   $0xc010a96c
c0105a76:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105a7b:	68 cc 00 00 00       	push   $0xcc
c0105a80:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105a85:	e8 66 a9 ff ff       	call   c01003f0 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0105a8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a8d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105a90:	74 10                	je     c0105aa2 <basic_check+0xbe>
c0105a92:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a95:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105a98:	74 08                	je     c0105aa2 <basic_check+0xbe>
c0105a9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a9d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105aa0:	75 19                	jne    c0105abb <basic_check+0xd7>
c0105aa2:	68 88 a9 10 c0       	push   $0xc010a988
c0105aa7:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105aac:	68 ce 00 00 00       	push   $0xce
c0105ab1:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105ab6:	e8 35 a9 ff ff       	call   c01003f0 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0105abb:	83 ec 0c             	sub    $0xc,%esp
c0105abe:	ff 75 ec             	pushl  -0x14(%ebp)
c0105ac1:	e8 1d f9 ff ff       	call   c01053e3 <page_ref>
c0105ac6:	83 c4 10             	add    $0x10,%esp
c0105ac9:	85 c0                	test   %eax,%eax
c0105acb:	75 24                	jne    c0105af1 <basic_check+0x10d>
c0105acd:	83 ec 0c             	sub    $0xc,%esp
c0105ad0:	ff 75 f0             	pushl  -0x10(%ebp)
c0105ad3:	e8 0b f9 ff ff       	call   c01053e3 <page_ref>
c0105ad8:	83 c4 10             	add    $0x10,%esp
c0105adb:	85 c0                	test   %eax,%eax
c0105add:	75 12                	jne    c0105af1 <basic_check+0x10d>
c0105adf:	83 ec 0c             	sub    $0xc,%esp
c0105ae2:	ff 75 f4             	pushl  -0xc(%ebp)
c0105ae5:	e8 f9 f8 ff ff       	call   c01053e3 <page_ref>
c0105aea:	83 c4 10             	add    $0x10,%esp
c0105aed:	85 c0                	test   %eax,%eax
c0105aef:	74 19                	je     c0105b0a <basic_check+0x126>
c0105af1:	68 ac a9 10 c0       	push   $0xc010a9ac
c0105af6:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105afb:	68 cf 00 00 00       	push   $0xcf
c0105b00:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105b05:	e8 e6 a8 ff ff       	call   c01003f0 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0105b0a:	83 ec 0c             	sub    $0xc,%esp
c0105b0d:	ff 75 ec             	pushl  -0x14(%ebp)
c0105b10:	e8 bb f8 ff ff       	call   c01053d0 <page2pa>
c0105b15:	83 c4 10             	add    $0x10,%esp
c0105b18:	89 c2                	mov    %eax,%edx
c0105b1a:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0105b1f:	c1 e0 0c             	shl    $0xc,%eax
c0105b22:	39 c2                	cmp    %eax,%edx
c0105b24:	72 19                	jb     c0105b3f <basic_check+0x15b>
c0105b26:	68 e8 a9 10 c0       	push   $0xc010a9e8
c0105b2b:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105b30:	68 d1 00 00 00       	push   $0xd1
c0105b35:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105b3a:	e8 b1 a8 ff ff       	call   c01003f0 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0105b3f:	83 ec 0c             	sub    $0xc,%esp
c0105b42:	ff 75 f0             	pushl  -0x10(%ebp)
c0105b45:	e8 86 f8 ff ff       	call   c01053d0 <page2pa>
c0105b4a:	83 c4 10             	add    $0x10,%esp
c0105b4d:	89 c2                	mov    %eax,%edx
c0105b4f:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0105b54:	c1 e0 0c             	shl    $0xc,%eax
c0105b57:	39 c2                	cmp    %eax,%edx
c0105b59:	72 19                	jb     c0105b74 <basic_check+0x190>
c0105b5b:	68 05 aa 10 c0       	push   $0xc010aa05
c0105b60:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105b65:	68 d2 00 00 00       	push   $0xd2
c0105b6a:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105b6f:	e8 7c a8 ff ff       	call   c01003f0 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0105b74:	83 ec 0c             	sub    $0xc,%esp
c0105b77:	ff 75 f4             	pushl  -0xc(%ebp)
c0105b7a:	e8 51 f8 ff ff       	call   c01053d0 <page2pa>
c0105b7f:	83 c4 10             	add    $0x10,%esp
c0105b82:	89 c2                	mov    %eax,%edx
c0105b84:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0105b89:	c1 e0 0c             	shl    $0xc,%eax
c0105b8c:	39 c2                	cmp    %eax,%edx
c0105b8e:	72 19                	jb     c0105ba9 <basic_check+0x1c5>
c0105b90:	68 22 aa 10 c0       	push   $0xc010aa22
c0105b95:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105b9a:	68 d3 00 00 00       	push   $0xd3
c0105b9f:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105ba4:	e8 47 a8 ff ff       	call   c01003f0 <__panic>

    list_entry_t free_list_store = free_list;
c0105ba9:	a1 44 a1 12 c0       	mov    0xc012a144,%eax
c0105bae:	8b 15 48 a1 12 c0    	mov    0xc012a148,%edx
c0105bb4:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105bb7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105bba:	c7 45 e4 44 a1 12 c0 	movl   $0xc012a144,-0x1c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0105bc1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105bc4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105bc7:	89 50 04             	mov    %edx,0x4(%eax)
c0105bca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105bcd:	8b 50 04             	mov    0x4(%eax),%edx
c0105bd0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105bd3:	89 10                	mov    %edx,(%eax)
c0105bd5:	c7 45 d8 44 a1 12 c0 	movl   $0xc012a144,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0105bdc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105bdf:	8b 40 04             	mov    0x4(%eax),%eax
c0105be2:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0105be5:	0f 94 c0             	sete   %al
c0105be8:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0105beb:	85 c0                	test   %eax,%eax
c0105bed:	75 19                	jne    c0105c08 <basic_check+0x224>
c0105bef:	68 3f aa 10 c0       	push   $0xc010aa3f
c0105bf4:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105bf9:	68 d7 00 00 00       	push   $0xd7
c0105bfe:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105c03:	e8 e8 a7 ff ff       	call   c01003f0 <__panic>

    unsigned int nr_free_store = nr_free;
c0105c08:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c0105c0d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c0105c10:	c7 05 4c a1 12 c0 00 	movl   $0x0,0xc012a14c
c0105c17:	00 00 00 

    assert(alloc_page() == NULL);
c0105c1a:	83 ec 0c             	sub    $0xc,%esp
c0105c1d:	6a 01                	push   $0x1
c0105c1f:	e8 ba 0a 00 00       	call   c01066de <alloc_pages>
c0105c24:	83 c4 10             	add    $0x10,%esp
c0105c27:	85 c0                	test   %eax,%eax
c0105c29:	74 19                	je     c0105c44 <basic_check+0x260>
c0105c2b:	68 56 aa 10 c0       	push   $0xc010aa56
c0105c30:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105c35:	68 dc 00 00 00       	push   $0xdc
c0105c3a:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105c3f:	e8 ac a7 ff ff       	call   c01003f0 <__panic>

    free_page(p0);
c0105c44:	83 ec 08             	sub    $0x8,%esp
c0105c47:	6a 01                	push   $0x1
c0105c49:	ff 75 ec             	pushl  -0x14(%ebp)
c0105c4c:	e8 f9 0a 00 00       	call   c010674a <free_pages>
c0105c51:	83 c4 10             	add    $0x10,%esp
    free_page(p1);
c0105c54:	83 ec 08             	sub    $0x8,%esp
c0105c57:	6a 01                	push   $0x1
c0105c59:	ff 75 f0             	pushl  -0x10(%ebp)
c0105c5c:	e8 e9 0a 00 00       	call   c010674a <free_pages>
c0105c61:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c0105c64:	83 ec 08             	sub    $0x8,%esp
c0105c67:	6a 01                	push   $0x1
c0105c69:	ff 75 f4             	pushl  -0xc(%ebp)
c0105c6c:	e8 d9 0a 00 00       	call   c010674a <free_pages>
c0105c71:	83 c4 10             	add    $0x10,%esp
    assert(nr_free == 3);
c0105c74:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c0105c79:	83 f8 03             	cmp    $0x3,%eax
c0105c7c:	74 19                	je     c0105c97 <basic_check+0x2b3>
c0105c7e:	68 6b aa 10 c0       	push   $0xc010aa6b
c0105c83:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105c88:	68 e1 00 00 00       	push   $0xe1
c0105c8d:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105c92:	e8 59 a7 ff ff       	call   c01003f0 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0105c97:	83 ec 0c             	sub    $0xc,%esp
c0105c9a:	6a 01                	push   $0x1
c0105c9c:	e8 3d 0a 00 00       	call   c01066de <alloc_pages>
c0105ca1:	83 c4 10             	add    $0x10,%esp
c0105ca4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105ca7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105cab:	75 19                	jne    c0105cc6 <basic_check+0x2e2>
c0105cad:	68 34 a9 10 c0       	push   $0xc010a934
c0105cb2:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105cb7:	68 e3 00 00 00       	push   $0xe3
c0105cbc:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105cc1:	e8 2a a7 ff ff       	call   c01003f0 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0105cc6:	83 ec 0c             	sub    $0xc,%esp
c0105cc9:	6a 01                	push   $0x1
c0105ccb:	e8 0e 0a 00 00       	call   c01066de <alloc_pages>
c0105cd0:	83 c4 10             	add    $0x10,%esp
c0105cd3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105cd6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105cda:	75 19                	jne    c0105cf5 <basic_check+0x311>
c0105cdc:	68 50 a9 10 c0       	push   $0xc010a950
c0105ce1:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105ce6:	68 e4 00 00 00       	push   $0xe4
c0105ceb:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105cf0:	e8 fb a6 ff ff       	call   c01003f0 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0105cf5:	83 ec 0c             	sub    $0xc,%esp
c0105cf8:	6a 01                	push   $0x1
c0105cfa:	e8 df 09 00 00       	call   c01066de <alloc_pages>
c0105cff:	83 c4 10             	add    $0x10,%esp
c0105d02:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105d05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105d09:	75 19                	jne    c0105d24 <basic_check+0x340>
c0105d0b:	68 6c a9 10 c0       	push   $0xc010a96c
c0105d10:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105d15:	68 e5 00 00 00       	push   $0xe5
c0105d1a:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105d1f:	e8 cc a6 ff ff       	call   c01003f0 <__panic>

    assert(alloc_page() == NULL);
c0105d24:	83 ec 0c             	sub    $0xc,%esp
c0105d27:	6a 01                	push   $0x1
c0105d29:	e8 b0 09 00 00       	call   c01066de <alloc_pages>
c0105d2e:	83 c4 10             	add    $0x10,%esp
c0105d31:	85 c0                	test   %eax,%eax
c0105d33:	74 19                	je     c0105d4e <basic_check+0x36a>
c0105d35:	68 56 aa 10 c0       	push   $0xc010aa56
c0105d3a:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105d3f:	68 e7 00 00 00       	push   $0xe7
c0105d44:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105d49:	e8 a2 a6 ff ff       	call   c01003f0 <__panic>

    free_page(p0);
c0105d4e:	83 ec 08             	sub    $0x8,%esp
c0105d51:	6a 01                	push   $0x1
c0105d53:	ff 75 ec             	pushl  -0x14(%ebp)
c0105d56:	e8 ef 09 00 00       	call   c010674a <free_pages>
c0105d5b:	83 c4 10             	add    $0x10,%esp
c0105d5e:	c7 45 e8 44 a1 12 c0 	movl   $0xc012a144,-0x18(%ebp)
c0105d65:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d68:	8b 40 04             	mov    0x4(%eax),%eax
c0105d6b:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105d6e:	0f 94 c0             	sete   %al
c0105d71:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0105d74:	85 c0                	test   %eax,%eax
c0105d76:	74 19                	je     c0105d91 <basic_check+0x3ad>
c0105d78:	68 78 aa 10 c0       	push   $0xc010aa78
c0105d7d:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105d82:	68 ea 00 00 00       	push   $0xea
c0105d87:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105d8c:	e8 5f a6 ff ff       	call   c01003f0 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0105d91:	83 ec 0c             	sub    $0xc,%esp
c0105d94:	6a 01                	push   $0x1
c0105d96:	e8 43 09 00 00       	call   c01066de <alloc_pages>
c0105d9b:	83 c4 10             	add    $0x10,%esp
c0105d9e:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105da1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105da4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105da7:	74 19                	je     c0105dc2 <basic_check+0x3de>
c0105da9:	68 90 aa 10 c0       	push   $0xc010aa90
c0105dae:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105db3:	68 ed 00 00 00       	push   $0xed
c0105db8:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105dbd:	e8 2e a6 ff ff       	call   c01003f0 <__panic>
    assert(alloc_page() == NULL);
c0105dc2:	83 ec 0c             	sub    $0xc,%esp
c0105dc5:	6a 01                	push   $0x1
c0105dc7:	e8 12 09 00 00       	call   c01066de <alloc_pages>
c0105dcc:	83 c4 10             	add    $0x10,%esp
c0105dcf:	85 c0                	test   %eax,%eax
c0105dd1:	74 19                	je     c0105dec <basic_check+0x408>
c0105dd3:	68 56 aa 10 c0       	push   $0xc010aa56
c0105dd8:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105ddd:	68 ee 00 00 00       	push   $0xee
c0105de2:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105de7:	e8 04 a6 ff ff       	call   c01003f0 <__panic>

    assert(nr_free == 0);
c0105dec:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c0105df1:	85 c0                	test   %eax,%eax
c0105df3:	74 19                	je     c0105e0e <basic_check+0x42a>
c0105df5:	68 a9 aa 10 c0       	push   $0xc010aaa9
c0105dfa:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105dff:	68 f0 00 00 00       	push   $0xf0
c0105e04:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105e09:	e8 e2 a5 ff ff       	call   c01003f0 <__panic>
    free_list = free_list_store;
c0105e0e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105e11:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105e14:	a3 44 a1 12 c0       	mov    %eax,0xc012a144
c0105e19:	89 15 48 a1 12 c0    	mov    %edx,0xc012a148
    nr_free = nr_free_store;
c0105e1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105e22:	a3 4c a1 12 c0       	mov    %eax,0xc012a14c

    free_page(p);
c0105e27:	83 ec 08             	sub    $0x8,%esp
c0105e2a:	6a 01                	push   $0x1
c0105e2c:	ff 75 dc             	pushl  -0x24(%ebp)
c0105e2f:	e8 16 09 00 00       	call   c010674a <free_pages>
c0105e34:	83 c4 10             	add    $0x10,%esp
    free_page(p1);
c0105e37:	83 ec 08             	sub    $0x8,%esp
c0105e3a:	6a 01                	push   $0x1
c0105e3c:	ff 75 f0             	pushl  -0x10(%ebp)
c0105e3f:	e8 06 09 00 00       	call   c010674a <free_pages>
c0105e44:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c0105e47:	83 ec 08             	sub    $0x8,%esp
c0105e4a:	6a 01                	push   $0x1
c0105e4c:	ff 75 f4             	pushl  -0xc(%ebp)
c0105e4f:	e8 f6 08 00 00       	call   c010674a <free_pages>
c0105e54:	83 c4 10             	add    $0x10,%esp
}
c0105e57:	90                   	nop
c0105e58:	c9                   	leave  
c0105e59:	c3                   	ret    

c0105e5a <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0105e5a:	55                   	push   %ebp
c0105e5b:	89 e5                	mov    %esp,%ebp
c0105e5d:	81 ec 88 00 00 00    	sub    $0x88,%esp
    int count = 0, total = 0;
c0105e63:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105e6a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0105e71:	c7 45 ec 44 a1 12 c0 	movl   $0xc012a144,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0105e78:	eb 60                	jmp    c0105eda <default_check+0x80>
        struct Page *p = le2page(le, page_link);
c0105e7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e7d:	83 e8 10             	sub    $0x10,%eax
c0105e80:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c0105e83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105e86:	83 c0 04             	add    $0x4,%eax
c0105e89:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0105e90:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105e93:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0105e96:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0105e99:	0f a3 10             	bt     %edx,(%eax)
c0105e9c:	19 c0                	sbb    %eax,%eax
c0105e9e:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c0105ea1:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c0105ea5:	0f 95 c0             	setne  %al
c0105ea8:	0f b6 c0             	movzbl %al,%eax
c0105eab:	85 c0                	test   %eax,%eax
c0105ead:	75 19                	jne    c0105ec8 <default_check+0x6e>
c0105eaf:	68 b6 aa 10 c0       	push   $0xc010aab6
c0105eb4:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105eb9:	68 01 01 00 00       	push   $0x101
c0105ebe:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105ec3:	e8 28 a5 ff ff       	call   c01003f0 <__panic>
        count ++, total += p->property;
c0105ec8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0105ecc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ecf:	8b 50 08             	mov    0x8(%eax),%edx
c0105ed2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ed5:	01 d0                	add    %edx,%eax
c0105ed7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105eda:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105edd:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0105ee0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105ee3:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0105ee6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105ee9:	81 7d ec 44 a1 12 c0 	cmpl   $0xc012a144,-0x14(%ebp)
c0105ef0:	75 88                	jne    c0105e7a <default_check+0x20>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c0105ef2:	e8 88 08 00 00       	call   c010677f <nr_free_pages>
c0105ef7:	89 c2                	mov    %eax,%edx
c0105ef9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105efc:	39 c2                	cmp    %eax,%edx
c0105efe:	74 19                	je     c0105f19 <default_check+0xbf>
c0105f00:	68 c6 aa 10 c0       	push   $0xc010aac6
c0105f05:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105f0a:	68 04 01 00 00       	push   $0x104
c0105f0f:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105f14:	e8 d7 a4 ff ff       	call   c01003f0 <__panic>

    basic_check();
c0105f19:	e8 c6 fa ff ff       	call   c01059e4 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0105f1e:	83 ec 0c             	sub    $0xc,%esp
c0105f21:	6a 05                	push   $0x5
c0105f23:	e8 b6 07 00 00       	call   c01066de <alloc_pages>
c0105f28:	83 c4 10             	add    $0x10,%esp
c0105f2b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    assert(p0 != NULL);
c0105f2e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105f32:	75 19                	jne    c0105f4d <default_check+0xf3>
c0105f34:	68 df aa 10 c0       	push   $0xc010aadf
c0105f39:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105f3e:	68 09 01 00 00       	push   $0x109
c0105f43:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105f48:	e8 a3 a4 ff ff       	call   c01003f0 <__panic>
    assert(!PageProperty(p0));
c0105f4d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105f50:	83 c0 04             	add    $0x4,%eax
c0105f53:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
c0105f5a:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105f5d:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0105f60:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105f63:	0f a3 10             	bt     %edx,(%eax)
c0105f66:	19 c0                	sbb    %eax,%eax
c0105f68:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
c0105f6b:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
c0105f6f:	0f 95 c0             	setne  %al
c0105f72:	0f b6 c0             	movzbl %al,%eax
c0105f75:	85 c0                	test   %eax,%eax
c0105f77:	74 19                	je     c0105f92 <default_check+0x138>
c0105f79:	68 ea aa 10 c0       	push   $0xc010aaea
c0105f7e:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105f83:	68 0a 01 00 00       	push   $0x10a
c0105f88:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105f8d:	e8 5e a4 ff ff       	call   c01003f0 <__panic>

    list_entry_t free_list_store = free_list;
c0105f92:	a1 44 a1 12 c0       	mov    0xc012a144,%eax
c0105f97:	8b 15 48 a1 12 c0    	mov    0xc012a148,%edx
c0105f9d:	89 45 80             	mov    %eax,-0x80(%ebp)
c0105fa0:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0105fa3:	c7 45 d0 44 a1 12 c0 	movl   $0xc012a144,-0x30(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0105faa:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105fad:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105fb0:	89 50 04             	mov    %edx,0x4(%eax)
c0105fb3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105fb6:	8b 50 04             	mov    0x4(%eax),%edx
c0105fb9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105fbc:	89 10                	mov    %edx,(%eax)
c0105fbe:	c7 45 d8 44 a1 12 c0 	movl   $0xc012a144,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0105fc5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105fc8:	8b 40 04             	mov    0x4(%eax),%eax
c0105fcb:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0105fce:	0f 94 c0             	sete   %al
c0105fd1:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0105fd4:	85 c0                	test   %eax,%eax
c0105fd6:	75 19                	jne    c0105ff1 <default_check+0x197>
c0105fd8:	68 3f aa 10 c0       	push   $0xc010aa3f
c0105fdd:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0105fe2:	68 0e 01 00 00       	push   $0x10e
c0105fe7:	68 cb a8 10 c0       	push   $0xc010a8cb
c0105fec:	e8 ff a3 ff ff       	call   c01003f0 <__panic>
    assert(alloc_page() == NULL);
c0105ff1:	83 ec 0c             	sub    $0xc,%esp
c0105ff4:	6a 01                	push   $0x1
c0105ff6:	e8 e3 06 00 00       	call   c01066de <alloc_pages>
c0105ffb:	83 c4 10             	add    $0x10,%esp
c0105ffe:	85 c0                	test   %eax,%eax
c0106000:	74 19                	je     c010601b <default_check+0x1c1>
c0106002:	68 56 aa 10 c0       	push   $0xc010aa56
c0106007:	68 b6 a8 10 c0       	push   $0xc010a8b6
c010600c:	68 0f 01 00 00       	push   $0x10f
c0106011:	68 cb a8 10 c0       	push   $0xc010a8cb
c0106016:	e8 d5 a3 ff ff       	call   c01003f0 <__panic>

    unsigned int nr_free_store = nr_free;
c010601b:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c0106020:	89 45 cc             	mov    %eax,-0x34(%ebp)
    nr_free = 0;
c0106023:	c7 05 4c a1 12 c0 00 	movl   $0x0,0xc012a14c
c010602a:	00 00 00 

    free_pages(p0 + 2, 3);
c010602d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106030:	83 c0 48             	add    $0x48,%eax
c0106033:	83 ec 08             	sub    $0x8,%esp
c0106036:	6a 03                	push   $0x3
c0106038:	50                   	push   %eax
c0106039:	e8 0c 07 00 00       	call   c010674a <free_pages>
c010603e:	83 c4 10             	add    $0x10,%esp
    assert(alloc_pages(4) == NULL);
c0106041:	83 ec 0c             	sub    $0xc,%esp
c0106044:	6a 04                	push   $0x4
c0106046:	e8 93 06 00 00       	call   c01066de <alloc_pages>
c010604b:	83 c4 10             	add    $0x10,%esp
c010604e:	85 c0                	test   %eax,%eax
c0106050:	74 19                	je     c010606b <default_check+0x211>
c0106052:	68 fc aa 10 c0       	push   $0xc010aafc
c0106057:	68 b6 a8 10 c0       	push   $0xc010a8b6
c010605c:	68 15 01 00 00       	push   $0x115
c0106061:	68 cb a8 10 c0       	push   $0xc010a8cb
c0106066:	e8 85 a3 ff ff       	call   c01003f0 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c010606b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010606e:	83 c0 48             	add    $0x48,%eax
c0106071:	83 c0 04             	add    $0x4,%eax
c0106074:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c010607b:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010607e:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0106081:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106084:	0f a3 10             	bt     %edx,(%eax)
c0106087:	19 c0                	sbb    %eax,%eax
c0106089:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c010608c:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0106090:	0f 95 c0             	setne  %al
c0106093:	0f b6 c0             	movzbl %al,%eax
c0106096:	85 c0                	test   %eax,%eax
c0106098:	74 0e                	je     c01060a8 <default_check+0x24e>
c010609a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010609d:	83 c0 48             	add    $0x48,%eax
c01060a0:	8b 40 08             	mov    0x8(%eax),%eax
c01060a3:	83 f8 03             	cmp    $0x3,%eax
c01060a6:	74 19                	je     c01060c1 <default_check+0x267>
c01060a8:	68 14 ab 10 c0       	push   $0xc010ab14
c01060ad:	68 b6 a8 10 c0       	push   $0xc010a8b6
c01060b2:	68 16 01 00 00       	push   $0x116
c01060b7:	68 cb a8 10 c0       	push   $0xc010a8cb
c01060bc:	e8 2f a3 ff ff       	call   c01003f0 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c01060c1:	83 ec 0c             	sub    $0xc,%esp
c01060c4:	6a 03                	push   $0x3
c01060c6:	e8 13 06 00 00       	call   c01066de <alloc_pages>
c01060cb:	83 c4 10             	add    $0x10,%esp
c01060ce:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c01060d1:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c01060d5:	75 19                	jne    c01060f0 <default_check+0x296>
c01060d7:	68 40 ab 10 c0       	push   $0xc010ab40
c01060dc:	68 b6 a8 10 c0       	push   $0xc010a8b6
c01060e1:	68 17 01 00 00       	push   $0x117
c01060e6:	68 cb a8 10 c0       	push   $0xc010a8cb
c01060eb:	e8 00 a3 ff ff       	call   c01003f0 <__panic>
    assert(alloc_page() == NULL);
c01060f0:	83 ec 0c             	sub    $0xc,%esp
c01060f3:	6a 01                	push   $0x1
c01060f5:	e8 e4 05 00 00       	call   c01066de <alloc_pages>
c01060fa:	83 c4 10             	add    $0x10,%esp
c01060fd:	85 c0                	test   %eax,%eax
c01060ff:	74 19                	je     c010611a <default_check+0x2c0>
c0106101:	68 56 aa 10 c0       	push   $0xc010aa56
c0106106:	68 b6 a8 10 c0       	push   $0xc010a8b6
c010610b:	68 18 01 00 00       	push   $0x118
c0106110:	68 cb a8 10 c0       	push   $0xc010a8cb
c0106115:	e8 d6 a2 ff ff       	call   c01003f0 <__panic>
    assert(p0 + 2 == p1);
c010611a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010611d:	83 c0 48             	add    $0x48,%eax
c0106120:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
c0106123:	74 19                	je     c010613e <default_check+0x2e4>
c0106125:	68 5e ab 10 c0       	push   $0xc010ab5e
c010612a:	68 b6 a8 10 c0       	push   $0xc010a8b6
c010612f:	68 19 01 00 00       	push   $0x119
c0106134:	68 cb a8 10 c0       	push   $0xc010a8cb
c0106139:	e8 b2 a2 ff ff       	call   c01003f0 <__panic>

    p2 = p0 + 1;
c010613e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106141:	83 c0 24             	add    $0x24,%eax
c0106144:	89 45 c0             	mov    %eax,-0x40(%ebp)
    free_page(p0);
c0106147:	83 ec 08             	sub    $0x8,%esp
c010614a:	6a 01                	push   $0x1
c010614c:	ff 75 dc             	pushl  -0x24(%ebp)
c010614f:	e8 f6 05 00 00       	call   c010674a <free_pages>
c0106154:	83 c4 10             	add    $0x10,%esp
    free_pages(p1, 3);
c0106157:	83 ec 08             	sub    $0x8,%esp
c010615a:	6a 03                	push   $0x3
c010615c:	ff 75 c4             	pushl  -0x3c(%ebp)
c010615f:	e8 e6 05 00 00       	call   c010674a <free_pages>
c0106164:	83 c4 10             	add    $0x10,%esp
    assert(PageProperty(p0) && p0->property == 1);
c0106167:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010616a:	83 c0 04             	add    $0x4,%eax
c010616d:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0106174:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106177:	8b 45 94             	mov    -0x6c(%ebp),%eax
c010617a:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010617d:	0f a3 10             	bt     %edx,(%eax)
c0106180:	19 c0                	sbb    %eax,%eax
c0106182:	89 45 90             	mov    %eax,-0x70(%ebp)
    return oldbit != 0;
c0106185:	83 7d 90 00          	cmpl   $0x0,-0x70(%ebp)
c0106189:	0f 95 c0             	setne  %al
c010618c:	0f b6 c0             	movzbl %al,%eax
c010618f:	85 c0                	test   %eax,%eax
c0106191:	74 0b                	je     c010619e <default_check+0x344>
c0106193:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106196:	8b 40 08             	mov    0x8(%eax),%eax
c0106199:	83 f8 01             	cmp    $0x1,%eax
c010619c:	74 19                	je     c01061b7 <default_check+0x35d>
c010619e:	68 6c ab 10 c0       	push   $0xc010ab6c
c01061a3:	68 b6 a8 10 c0       	push   $0xc010a8b6
c01061a8:	68 1e 01 00 00       	push   $0x11e
c01061ad:	68 cb a8 10 c0       	push   $0xc010a8cb
c01061b2:	e8 39 a2 ff ff       	call   c01003f0 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01061b7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01061ba:	83 c0 04             	add    $0x4,%eax
c01061bd:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c01061c4:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01061c7:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01061ca:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01061cd:	0f a3 10             	bt     %edx,(%eax)
c01061d0:	19 c0                	sbb    %eax,%eax
c01061d2:	89 45 88             	mov    %eax,-0x78(%ebp)
    return oldbit != 0;
c01061d5:	83 7d 88 00          	cmpl   $0x0,-0x78(%ebp)
c01061d9:	0f 95 c0             	setne  %al
c01061dc:	0f b6 c0             	movzbl %al,%eax
c01061df:	85 c0                	test   %eax,%eax
c01061e1:	74 0b                	je     c01061ee <default_check+0x394>
c01061e3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01061e6:	8b 40 08             	mov    0x8(%eax),%eax
c01061e9:	83 f8 03             	cmp    $0x3,%eax
c01061ec:	74 19                	je     c0106207 <default_check+0x3ad>
c01061ee:	68 94 ab 10 c0       	push   $0xc010ab94
c01061f3:	68 b6 a8 10 c0       	push   $0xc010a8b6
c01061f8:	68 1f 01 00 00       	push   $0x11f
c01061fd:	68 cb a8 10 c0       	push   $0xc010a8cb
c0106202:	e8 e9 a1 ff ff       	call   c01003f0 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0106207:	83 ec 0c             	sub    $0xc,%esp
c010620a:	6a 01                	push   $0x1
c010620c:	e8 cd 04 00 00       	call   c01066de <alloc_pages>
c0106211:	83 c4 10             	add    $0x10,%esp
c0106214:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0106217:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010621a:	83 e8 24             	sub    $0x24,%eax
c010621d:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0106220:	74 19                	je     c010623b <default_check+0x3e1>
c0106222:	68 ba ab 10 c0       	push   $0xc010abba
c0106227:	68 b6 a8 10 c0       	push   $0xc010a8b6
c010622c:	68 21 01 00 00       	push   $0x121
c0106231:	68 cb a8 10 c0       	push   $0xc010a8cb
c0106236:	e8 b5 a1 ff ff       	call   c01003f0 <__panic>
    free_page(p0);
c010623b:	83 ec 08             	sub    $0x8,%esp
c010623e:	6a 01                	push   $0x1
c0106240:	ff 75 dc             	pushl  -0x24(%ebp)
c0106243:	e8 02 05 00 00       	call   c010674a <free_pages>
c0106248:	83 c4 10             	add    $0x10,%esp
    assert((p0 = alloc_pages(2)) == p2 + 1);
c010624b:	83 ec 0c             	sub    $0xc,%esp
c010624e:	6a 02                	push   $0x2
c0106250:	e8 89 04 00 00       	call   c01066de <alloc_pages>
c0106255:	83 c4 10             	add    $0x10,%esp
c0106258:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010625b:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010625e:	83 c0 24             	add    $0x24,%eax
c0106261:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0106264:	74 19                	je     c010627f <default_check+0x425>
c0106266:	68 d8 ab 10 c0       	push   $0xc010abd8
c010626b:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0106270:	68 23 01 00 00       	push   $0x123
c0106275:	68 cb a8 10 c0       	push   $0xc010a8cb
c010627a:	e8 71 a1 ff ff       	call   c01003f0 <__panic>

    free_pages(p0, 2);
c010627f:	83 ec 08             	sub    $0x8,%esp
c0106282:	6a 02                	push   $0x2
c0106284:	ff 75 dc             	pushl  -0x24(%ebp)
c0106287:	e8 be 04 00 00       	call   c010674a <free_pages>
c010628c:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c010628f:	83 ec 08             	sub    $0x8,%esp
c0106292:	6a 01                	push   $0x1
c0106294:	ff 75 c0             	pushl  -0x40(%ebp)
c0106297:	e8 ae 04 00 00       	call   c010674a <free_pages>
c010629c:	83 c4 10             	add    $0x10,%esp

    assert((p0 = alloc_pages(5)) != NULL);
c010629f:	83 ec 0c             	sub    $0xc,%esp
c01062a2:	6a 05                	push   $0x5
c01062a4:	e8 35 04 00 00       	call   c01066de <alloc_pages>
c01062a9:	83 c4 10             	add    $0x10,%esp
c01062ac:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01062af:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01062b3:	75 19                	jne    c01062ce <default_check+0x474>
c01062b5:	68 f8 ab 10 c0       	push   $0xc010abf8
c01062ba:	68 b6 a8 10 c0       	push   $0xc010a8b6
c01062bf:	68 28 01 00 00       	push   $0x128
c01062c4:	68 cb a8 10 c0       	push   $0xc010a8cb
c01062c9:	e8 22 a1 ff ff       	call   c01003f0 <__panic>
    assert(alloc_page() == NULL);
c01062ce:	83 ec 0c             	sub    $0xc,%esp
c01062d1:	6a 01                	push   $0x1
c01062d3:	e8 06 04 00 00       	call   c01066de <alloc_pages>
c01062d8:	83 c4 10             	add    $0x10,%esp
c01062db:	85 c0                	test   %eax,%eax
c01062dd:	74 19                	je     c01062f8 <default_check+0x49e>
c01062df:	68 56 aa 10 c0       	push   $0xc010aa56
c01062e4:	68 b6 a8 10 c0       	push   $0xc010a8b6
c01062e9:	68 29 01 00 00       	push   $0x129
c01062ee:	68 cb a8 10 c0       	push   $0xc010a8cb
c01062f3:	e8 f8 a0 ff ff       	call   c01003f0 <__panic>

    assert(nr_free == 0);
c01062f8:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c01062fd:	85 c0                	test   %eax,%eax
c01062ff:	74 19                	je     c010631a <default_check+0x4c0>
c0106301:	68 a9 aa 10 c0       	push   $0xc010aaa9
c0106306:	68 b6 a8 10 c0       	push   $0xc010a8b6
c010630b:	68 2b 01 00 00       	push   $0x12b
c0106310:	68 cb a8 10 c0       	push   $0xc010a8cb
c0106315:	e8 d6 a0 ff ff       	call   c01003f0 <__panic>
    nr_free = nr_free_store;
c010631a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010631d:	a3 4c a1 12 c0       	mov    %eax,0xc012a14c

    free_list = free_list_store;
c0106322:	8b 45 80             	mov    -0x80(%ebp),%eax
c0106325:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0106328:	a3 44 a1 12 c0       	mov    %eax,0xc012a144
c010632d:	89 15 48 a1 12 c0    	mov    %edx,0xc012a148
    free_pages(p0, 5);
c0106333:	83 ec 08             	sub    $0x8,%esp
c0106336:	6a 05                	push   $0x5
c0106338:	ff 75 dc             	pushl  -0x24(%ebp)
c010633b:	e8 0a 04 00 00       	call   c010674a <free_pages>
c0106340:	83 c4 10             	add    $0x10,%esp

    le = &free_list;
c0106343:	c7 45 ec 44 a1 12 c0 	movl   $0xc012a144,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010634a:	eb 1d                	jmp    c0106369 <default_check+0x50f>
        struct Page *p = le2page(le, page_link);
c010634c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010634f:	83 e8 10             	sub    $0x10,%eax
c0106352:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        count --, total -= p->property;
c0106355:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0106359:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010635c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010635f:	8b 40 08             	mov    0x8(%eax),%eax
c0106362:	29 c2                	sub    %eax,%edx
c0106364:	89 d0                	mov    %edx,%eax
c0106366:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106369:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010636c:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010636f:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106372:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0106375:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106378:	81 7d ec 44 a1 12 c0 	cmpl   $0xc012a144,-0x14(%ebp)
c010637f:	75 cb                	jne    c010634c <default_check+0x4f2>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c0106381:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106385:	74 19                	je     c01063a0 <default_check+0x546>
c0106387:	68 16 ac 10 c0       	push   $0xc010ac16
c010638c:	68 b6 a8 10 c0       	push   $0xc010a8b6
c0106391:	68 36 01 00 00       	push   $0x136
c0106396:	68 cb a8 10 c0       	push   $0xc010a8cb
c010639b:	e8 50 a0 ff ff       	call   c01003f0 <__panic>
    assert(total == 0);
c01063a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01063a4:	74 19                	je     c01063bf <default_check+0x565>
c01063a6:	68 21 ac 10 c0       	push   $0xc010ac21
c01063ab:	68 b6 a8 10 c0       	push   $0xc010a8b6
c01063b0:	68 37 01 00 00       	push   $0x137
c01063b5:	68 cb a8 10 c0       	push   $0xc010a8cb
c01063ba:	e8 31 a0 ff ff       	call   c01003f0 <__panic>
}
c01063bf:	90                   	nop
c01063c0:	c9                   	leave  
c01063c1:	c3                   	ret    

c01063c2 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01063c2:	55                   	push   %ebp
c01063c3:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01063c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01063c8:	8b 15 58 a1 12 c0    	mov    0xc012a158,%edx
c01063ce:	29 d0                	sub    %edx,%eax
c01063d0:	c1 f8 02             	sar    $0x2,%eax
c01063d3:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c01063d9:	5d                   	pop    %ebp
c01063da:	c3                   	ret    

c01063db <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01063db:	55                   	push   %ebp
c01063dc:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c01063de:	ff 75 08             	pushl  0x8(%ebp)
c01063e1:	e8 dc ff ff ff       	call   c01063c2 <page2ppn>
c01063e6:	83 c4 04             	add    $0x4,%esp
c01063e9:	c1 e0 0c             	shl    $0xc,%eax
}
c01063ec:	c9                   	leave  
c01063ed:	c3                   	ret    

c01063ee <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c01063ee:	55                   	push   %ebp
c01063ef:	89 e5                	mov    %esp,%ebp
c01063f1:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c01063f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01063f7:	c1 e8 0c             	shr    $0xc,%eax
c01063fa:	89 c2                	mov    %eax,%edx
c01063fc:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0106401:	39 c2                	cmp    %eax,%edx
c0106403:	72 14                	jb     c0106419 <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0106405:	83 ec 04             	sub    $0x4,%esp
c0106408:	68 5c ac 10 c0       	push   $0xc010ac5c
c010640d:	6a 5f                	push   $0x5f
c010640f:	68 7b ac 10 c0       	push   $0xc010ac7b
c0106414:	e8 d7 9f ff ff       	call   c01003f0 <__panic>
    }
    return &pages[PPN(pa)];
c0106419:	8b 0d 58 a1 12 c0    	mov    0xc012a158,%ecx
c010641f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106422:	c1 e8 0c             	shr    $0xc,%eax
c0106425:	89 c2                	mov    %eax,%edx
c0106427:	89 d0                	mov    %edx,%eax
c0106429:	c1 e0 03             	shl    $0x3,%eax
c010642c:	01 d0                	add    %edx,%eax
c010642e:	c1 e0 02             	shl    $0x2,%eax
c0106431:	01 c8                	add    %ecx,%eax
}
c0106433:	c9                   	leave  
c0106434:	c3                   	ret    

c0106435 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0106435:	55                   	push   %ebp
c0106436:	89 e5                	mov    %esp,%ebp
c0106438:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c010643b:	ff 75 08             	pushl  0x8(%ebp)
c010643e:	e8 98 ff ff ff       	call   c01063db <page2pa>
c0106443:	83 c4 04             	add    $0x4,%esp
c0106446:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106449:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010644c:	c1 e8 0c             	shr    $0xc,%eax
c010644f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106452:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0106457:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010645a:	72 14                	jb     c0106470 <page2kva+0x3b>
c010645c:	ff 75 f4             	pushl  -0xc(%ebp)
c010645f:	68 8c ac 10 c0       	push   $0xc010ac8c
c0106464:	6a 66                	push   $0x66
c0106466:	68 7b ac 10 c0       	push   $0xc010ac7b
c010646b:	e8 80 9f ff ff       	call   c01003f0 <__panic>
c0106470:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106473:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0106478:	c9                   	leave  
c0106479:	c3                   	ret    

c010647a <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c010647a:	55                   	push   %ebp
c010647b:	89 e5                	mov    %esp,%ebp
c010647d:	83 ec 08             	sub    $0x8,%esp
    if (!(pte & PTE_P)) {
c0106480:	8b 45 08             	mov    0x8(%ebp),%eax
c0106483:	83 e0 01             	and    $0x1,%eax
c0106486:	85 c0                	test   %eax,%eax
c0106488:	75 14                	jne    c010649e <pte2page+0x24>
        panic("pte2page called with invalid pte");
c010648a:	83 ec 04             	sub    $0x4,%esp
c010648d:	68 b0 ac 10 c0       	push   $0xc010acb0
c0106492:	6a 71                	push   $0x71
c0106494:	68 7b ac 10 c0       	push   $0xc010ac7b
c0106499:	e8 52 9f ff ff       	call   c01003f0 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c010649e:	8b 45 08             	mov    0x8(%ebp),%eax
c01064a1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01064a6:	83 ec 0c             	sub    $0xc,%esp
c01064a9:	50                   	push   %eax
c01064aa:	e8 3f ff ff ff       	call   c01063ee <pa2page>
c01064af:	83 c4 10             	add    $0x10,%esp
}
c01064b2:	c9                   	leave  
c01064b3:	c3                   	ret    

c01064b4 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c01064b4:	55                   	push   %ebp
c01064b5:	89 e5                	mov    %esp,%ebp
c01064b7:	83 ec 08             	sub    $0x8,%esp
    return pa2page(PDE_ADDR(pde));
c01064ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01064bd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01064c2:	83 ec 0c             	sub    $0xc,%esp
c01064c5:	50                   	push   %eax
c01064c6:	e8 23 ff ff ff       	call   c01063ee <pa2page>
c01064cb:	83 c4 10             	add    $0x10,%esp
}
c01064ce:	c9                   	leave  
c01064cf:	c3                   	ret    

c01064d0 <page_ref>:

static inline int
page_ref(struct Page *page) {
c01064d0:	55                   	push   %ebp
c01064d1:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01064d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01064d6:	8b 00                	mov    (%eax),%eax
}
c01064d8:	5d                   	pop    %ebp
c01064d9:	c3                   	ret    

c01064da <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01064da:	55                   	push   %ebp
c01064db:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01064dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01064e0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01064e3:	89 10                	mov    %edx,(%eax)
}
c01064e5:	90                   	nop
c01064e6:	5d                   	pop    %ebp
c01064e7:	c3                   	ret    

c01064e8 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c01064e8:	55                   	push   %ebp
c01064e9:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c01064eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01064ee:	8b 00                	mov    (%eax),%eax
c01064f0:	8d 50 01             	lea    0x1(%eax),%edx
c01064f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01064f6:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01064f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01064fb:	8b 00                	mov    (%eax),%eax
}
c01064fd:	5d                   	pop    %ebp
c01064fe:	c3                   	ret    

c01064ff <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c01064ff:	55                   	push   %ebp
c0106500:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0106502:	8b 45 08             	mov    0x8(%ebp),%eax
c0106505:	8b 00                	mov    (%eax),%eax
c0106507:	8d 50 ff             	lea    -0x1(%eax),%edx
c010650a:	8b 45 08             	mov    0x8(%ebp),%eax
c010650d:	89 10                	mov    %edx,(%eax)
    return page->ref;
c010650f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106512:	8b 00                	mov    (%eax),%eax
}
c0106514:	5d                   	pop    %ebp
c0106515:	c3                   	ret    

c0106516 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0106516:	55                   	push   %ebp
c0106517:	89 e5                	mov    %esp,%ebp
c0106519:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010651c:	9c                   	pushf  
c010651d:	58                   	pop    %eax
c010651e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0106521:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0106524:	25 00 02 00 00       	and    $0x200,%eax
c0106529:	85 c0                	test   %eax,%eax
c010652b:	74 0c                	je     c0106539 <__intr_save+0x23>
        intr_disable();
c010652d:	e8 e0 ba ff ff       	call   c0102012 <intr_disable>
        return 1;
c0106532:	b8 01 00 00 00       	mov    $0x1,%eax
c0106537:	eb 05                	jmp    c010653e <__intr_save+0x28>
    }
    return 0;
c0106539:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010653e:	c9                   	leave  
c010653f:	c3                   	ret    

c0106540 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0106540:	55                   	push   %ebp
c0106541:	89 e5                	mov    %esp,%ebp
c0106543:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0106546:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010654a:	74 05                	je     c0106551 <__intr_restore+0x11>
        intr_enable();
c010654c:	e8 ba ba ff ff       	call   c010200b <intr_enable>
    }
}
c0106551:	90                   	nop
c0106552:	c9                   	leave  
c0106553:	c3                   	ret    

c0106554 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0106554:	55                   	push   %ebp
c0106555:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0106557:	8b 45 08             	mov    0x8(%ebp),%eax
c010655a:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c010655d:	b8 23 00 00 00       	mov    $0x23,%eax
c0106562:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0106564:	b8 23 00 00 00       	mov    $0x23,%eax
c0106569:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c010656b:	b8 10 00 00 00       	mov    $0x10,%eax
c0106570:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0106572:	b8 10 00 00 00       	mov    $0x10,%eax
c0106577:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0106579:	b8 10 00 00 00       	mov    $0x10,%eax
c010657e:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0106580:	ea 87 65 10 c0 08 00 	ljmp   $0x8,$0xc0106587
}
c0106587:	90                   	nop
c0106588:	5d                   	pop    %ebp
c0106589:	c3                   	ret    

c010658a <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c010658a:	55                   	push   %ebp
c010658b:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c010658d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106590:	a3 a4 7f 12 c0       	mov    %eax,0xc0127fa4
}
c0106595:	90                   	nop
c0106596:	5d                   	pop    %ebp
c0106597:	c3                   	ret    

c0106598 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0106598:	55                   	push   %ebp
c0106599:	89 e5                	mov    %esp,%ebp
c010659b:	83 ec 10             	sub    $0x10,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c010659e:	b8 00 40 12 c0       	mov    $0xc0124000,%eax
c01065a3:	50                   	push   %eax
c01065a4:	e8 e1 ff ff ff       	call   c010658a <load_esp0>
c01065a9:	83 c4 04             	add    $0x4,%esp
    ts.ts_ss0 = KERNEL_DS;
c01065ac:	66 c7 05 a8 7f 12 c0 	movw   $0x10,0xc0127fa8
c01065b3:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c01065b5:	66 c7 05 68 4a 12 c0 	movw   $0x68,0xc0124a68
c01065bc:	68 00 
c01065be:	b8 a0 7f 12 c0       	mov    $0xc0127fa0,%eax
c01065c3:	66 a3 6a 4a 12 c0    	mov    %ax,0xc0124a6a
c01065c9:	b8 a0 7f 12 c0       	mov    $0xc0127fa0,%eax
c01065ce:	c1 e8 10             	shr    $0x10,%eax
c01065d1:	a2 6c 4a 12 c0       	mov    %al,0xc0124a6c
c01065d6:	0f b6 05 6d 4a 12 c0 	movzbl 0xc0124a6d,%eax
c01065dd:	83 e0 f0             	and    $0xfffffff0,%eax
c01065e0:	83 c8 09             	or     $0x9,%eax
c01065e3:	a2 6d 4a 12 c0       	mov    %al,0xc0124a6d
c01065e8:	0f b6 05 6d 4a 12 c0 	movzbl 0xc0124a6d,%eax
c01065ef:	83 e0 ef             	and    $0xffffffef,%eax
c01065f2:	a2 6d 4a 12 c0       	mov    %al,0xc0124a6d
c01065f7:	0f b6 05 6d 4a 12 c0 	movzbl 0xc0124a6d,%eax
c01065fe:	83 e0 9f             	and    $0xffffff9f,%eax
c0106601:	a2 6d 4a 12 c0       	mov    %al,0xc0124a6d
c0106606:	0f b6 05 6d 4a 12 c0 	movzbl 0xc0124a6d,%eax
c010660d:	83 c8 80             	or     $0xffffff80,%eax
c0106610:	a2 6d 4a 12 c0       	mov    %al,0xc0124a6d
c0106615:	0f b6 05 6e 4a 12 c0 	movzbl 0xc0124a6e,%eax
c010661c:	83 e0 f0             	and    $0xfffffff0,%eax
c010661f:	a2 6e 4a 12 c0       	mov    %al,0xc0124a6e
c0106624:	0f b6 05 6e 4a 12 c0 	movzbl 0xc0124a6e,%eax
c010662b:	83 e0 ef             	and    $0xffffffef,%eax
c010662e:	a2 6e 4a 12 c0       	mov    %al,0xc0124a6e
c0106633:	0f b6 05 6e 4a 12 c0 	movzbl 0xc0124a6e,%eax
c010663a:	83 e0 df             	and    $0xffffffdf,%eax
c010663d:	a2 6e 4a 12 c0       	mov    %al,0xc0124a6e
c0106642:	0f b6 05 6e 4a 12 c0 	movzbl 0xc0124a6e,%eax
c0106649:	83 c8 40             	or     $0x40,%eax
c010664c:	a2 6e 4a 12 c0       	mov    %al,0xc0124a6e
c0106651:	0f b6 05 6e 4a 12 c0 	movzbl 0xc0124a6e,%eax
c0106658:	83 e0 7f             	and    $0x7f,%eax
c010665b:	a2 6e 4a 12 c0       	mov    %al,0xc0124a6e
c0106660:	b8 a0 7f 12 c0       	mov    $0xc0127fa0,%eax
c0106665:	c1 e8 18             	shr    $0x18,%eax
c0106668:	a2 6f 4a 12 c0       	mov    %al,0xc0124a6f

    // reload all segment registers
    lgdt(&gdt_pd);
c010666d:	68 70 4a 12 c0       	push   $0xc0124a70
c0106672:	e8 dd fe ff ff       	call   c0106554 <lgdt>
c0106677:	83 c4 04             	add    $0x4,%esp
c010667a:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0106680:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0106684:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0106687:	90                   	nop
c0106688:	c9                   	leave  
c0106689:	c3                   	ret    

c010668a <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c010668a:	55                   	push   %ebp
c010668b:	89 e5                	mov    %esp,%ebp
c010668d:	83 ec 08             	sub    $0x8,%esp
    pmm_manager = &default_pmm_manager;
c0106690:	c7 05 50 a1 12 c0 40 	movl   $0xc010ac40,0xc012a150
c0106697:	ac 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c010669a:	a1 50 a1 12 c0       	mov    0xc012a150,%eax
c010669f:	8b 00                	mov    (%eax),%eax
c01066a1:	83 ec 08             	sub    $0x8,%esp
c01066a4:	50                   	push   %eax
c01066a5:	68 dc ac 10 c0       	push   $0xc010acdc
c01066aa:	e8 db 9b ff ff       	call   c010028a <cprintf>
c01066af:	83 c4 10             	add    $0x10,%esp
    pmm_manager->init();
c01066b2:	a1 50 a1 12 c0       	mov    0xc012a150,%eax
c01066b7:	8b 40 04             	mov    0x4(%eax),%eax
c01066ba:	ff d0                	call   *%eax
}
c01066bc:	90                   	nop
c01066bd:	c9                   	leave  
c01066be:	c3                   	ret    

c01066bf <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c01066bf:	55                   	push   %ebp
c01066c0:	89 e5                	mov    %esp,%ebp
c01066c2:	83 ec 08             	sub    $0x8,%esp
    pmm_manager->init_memmap(base, n);
c01066c5:	a1 50 a1 12 c0       	mov    0xc012a150,%eax
c01066ca:	8b 40 08             	mov    0x8(%eax),%eax
c01066cd:	83 ec 08             	sub    $0x8,%esp
c01066d0:	ff 75 0c             	pushl  0xc(%ebp)
c01066d3:	ff 75 08             	pushl  0x8(%ebp)
c01066d6:	ff d0                	call   *%eax
c01066d8:	83 c4 10             	add    $0x10,%esp
}
c01066db:	90                   	nop
c01066dc:	c9                   	leave  
c01066dd:	c3                   	ret    

c01066de <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c01066de:	55                   	push   %ebp
c01066df:	89 e5                	mov    %esp,%ebp
c01066e1:	83 ec 18             	sub    $0x18,%esp
    struct Page *page=NULL;
c01066e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c01066eb:	e8 26 fe ff ff       	call   c0106516 <__intr_save>
c01066f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c01066f3:	a1 50 a1 12 c0       	mov    0xc012a150,%eax
c01066f8:	8b 40 0c             	mov    0xc(%eax),%eax
c01066fb:	83 ec 0c             	sub    $0xc,%esp
c01066fe:	ff 75 08             	pushl  0x8(%ebp)
c0106701:	ff d0                	call   *%eax
c0106703:	83 c4 10             	add    $0x10,%esp
c0106706:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c0106709:	83 ec 0c             	sub    $0xc,%esp
c010670c:	ff 75 f0             	pushl  -0x10(%ebp)
c010670f:	e8 2c fe ff ff       	call   c0106540 <__intr_restore>
c0106714:	83 c4 10             	add    $0x10,%esp

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c0106717:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010671b:	75 28                	jne    c0106745 <alloc_pages+0x67>
c010671d:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c0106721:	77 22                	ja     c0106745 <alloc_pages+0x67>
c0106723:	a1 6c 7f 12 c0       	mov    0xc0127f6c,%eax
c0106728:	85 c0                	test   %eax,%eax
c010672a:	74 19                	je     c0106745 <alloc_pages+0x67>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c010672c:	8b 55 08             	mov    0x8(%ebp),%edx
c010672f:	a1 58 a0 12 c0       	mov    0xc012a058,%eax
c0106734:	83 ec 04             	sub    $0x4,%esp
c0106737:	6a 00                	push   $0x0
c0106739:	52                   	push   %edx
c010673a:	50                   	push   %eax
c010673b:	e8 47 e3 ff ff       	call   c0104a87 <swap_out>
c0106740:	83 c4 10             	add    $0x10,%esp
    }
c0106743:	eb a6                	jmp    c01066eb <alloc_pages+0xd>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c0106745:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106748:	c9                   	leave  
c0106749:	c3                   	ret    

c010674a <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c010674a:	55                   	push   %ebp
c010674b:	89 e5                	mov    %esp,%ebp
c010674d:	83 ec 18             	sub    $0x18,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0106750:	e8 c1 fd ff ff       	call   c0106516 <__intr_save>
c0106755:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0106758:	a1 50 a1 12 c0       	mov    0xc012a150,%eax
c010675d:	8b 40 10             	mov    0x10(%eax),%eax
c0106760:	83 ec 08             	sub    $0x8,%esp
c0106763:	ff 75 0c             	pushl  0xc(%ebp)
c0106766:	ff 75 08             	pushl  0x8(%ebp)
c0106769:	ff d0                	call   *%eax
c010676b:	83 c4 10             	add    $0x10,%esp
    }
    local_intr_restore(intr_flag);
c010676e:	83 ec 0c             	sub    $0xc,%esp
c0106771:	ff 75 f4             	pushl  -0xc(%ebp)
c0106774:	e8 c7 fd ff ff       	call   c0106540 <__intr_restore>
c0106779:	83 c4 10             	add    $0x10,%esp
}
c010677c:	90                   	nop
c010677d:	c9                   	leave  
c010677e:	c3                   	ret    

c010677f <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c010677f:	55                   	push   %ebp
c0106780:	89 e5                	mov    %esp,%ebp
c0106782:	83 ec 18             	sub    $0x18,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0106785:	e8 8c fd ff ff       	call   c0106516 <__intr_save>
c010678a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c010678d:	a1 50 a1 12 c0       	mov    0xc012a150,%eax
c0106792:	8b 40 14             	mov    0x14(%eax),%eax
c0106795:	ff d0                	call   *%eax
c0106797:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c010679a:	83 ec 0c             	sub    $0xc,%esp
c010679d:	ff 75 f4             	pushl  -0xc(%ebp)
c01067a0:	e8 9b fd ff ff       	call   c0106540 <__intr_restore>
c01067a5:	83 c4 10             	add    $0x10,%esp
    return ret;
c01067a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01067ab:	c9                   	leave  
c01067ac:	c3                   	ret    

c01067ad <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c01067ad:	55                   	push   %ebp
c01067ae:	89 e5                	mov    %esp,%ebp
c01067b0:	57                   	push   %edi
c01067b1:	56                   	push   %esi
c01067b2:	53                   	push   %ebx
c01067b3:	83 ec 7c             	sub    $0x7c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c01067b6:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c01067bd:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c01067c4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c01067cb:	83 ec 0c             	sub    $0xc,%esp
c01067ce:	68 f3 ac 10 c0       	push   $0xc010acf3
c01067d3:	e8 b2 9a ff ff       	call   c010028a <cprintf>
c01067d8:	83 c4 10             	add    $0x10,%esp
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c01067db:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01067e2:	e9 fc 00 00 00       	jmp    c01068e3 <page_init+0x136>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01067e7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01067ea:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01067ed:	89 d0                	mov    %edx,%eax
c01067ef:	c1 e0 02             	shl    $0x2,%eax
c01067f2:	01 d0                	add    %edx,%eax
c01067f4:	c1 e0 02             	shl    $0x2,%eax
c01067f7:	01 c8                	add    %ecx,%eax
c01067f9:	8b 50 08             	mov    0x8(%eax),%edx
c01067fc:	8b 40 04             	mov    0x4(%eax),%eax
c01067ff:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0106802:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0106805:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106808:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010680b:	89 d0                	mov    %edx,%eax
c010680d:	c1 e0 02             	shl    $0x2,%eax
c0106810:	01 d0                	add    %edx,%eax
c0106812:	c1 e0 02             	shl    $0x2,%eax
c0106815:	01 c8                	add    %ecx,%eax
c0106817:	8b 48 0c             	mov    0xc(%eax),%ecx
c010681a:	8b 58 10             	mov    0x10(%eax),%ebx
c010681d:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106820:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0106823:	01 c8                	add    %ecx,%eax
c0106825:	11 da                	adc    %ebx,%edx
c0106827:	89 45 b0             	mov    %eax,-0x50(%ebp)
c010682a:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c010682d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106830:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106833:	89 d0                	mov    %edx,%eax
c0106835:	c1 e0 02             	shl    $0x2,%eax
c0106838:	01 d0                	add    %edx,%eax
c010683a:	c1 e0 02             	shl    $0x2,%eax
c010683d:	01 c8                	add    %ecx,%eax
c010683f:	83 c0 14             	add    $0x14,%eax
c0106842:	8b 00                	mov    (%eax),%eax
c0106844:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0106847:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010684a:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010684d:	83 c0 ff             	add    $0xffffffff,%eax
c0106850:	83 d2 ff             	adc    $0xffffffff,%edx
c0106853:	89 c1                	mov    %eax,%ecx
c0106855:	89 d3                	mov    %edx,%ebx
c0106857:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010685a:	89 55 80             	mov    %edx,-0x80(%ebp)
c010685d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106860:	89 d0                	mov    %edx,%eax
c0106862:	c1 e0 02             	shl    $0x2,%eax
c0106865:	01 d0                	add    %edx,%eax
c0106867:	c1 e0 02             	shl    $0x2,%eax
c010686a:	03 45 80             	add    -0x80(%ebp),%eax
c010686d:	8b 50 10             	mov    0x10(%eax),%edx
c0106870:	8b 40 0c             	mov    0xc(%eax),%eax
c0106873:	ff 75 84             	pushl  -0x7c(%ebp)
c0106876:	53                   	push   %ebx
c0106877:	51                   	push   %ecx
c0106878:	ff 75 bc             	pushl  -0x44(%ebp)
c010687b:	ff 75 b8             	pushl  -0x48(%ebp)
c010687e:	52                   	push   %edx
c010687f:	50                   	push   %eax
c0106880:	68 00 ad 10 c0       	push   $0xc010ad00
c0106885:	e8 00 9a ff ff       	call   c010028a <cprintf>
c010688a:	83 c4 20             	add    $0x20,%esp
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c010688d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106890:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106893:	89 d0                	mov    %edx,%eax
c0106895:	c1 e0 02             	shl    $0x2,%eax
c0106898:	01 d0                	add    %edx,%eax
c010689a:	c1 e0 02             	shl    $0x2,%eax
c010689d:	01 c8                	add    %ecx,%eax
c010689f:	83 c0 14             	add    $0x14,%eax
c01068a2:	8b 00                	mov    (%eax),%eax
c01068a4:	83 f8 01             	cmp    $0x1,%eax
c01068a7:	75 36                	jne    c01068df <page_init+0x132>
            if (maxpa < end && begin < KMEMSIZE) {
c01068a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01068ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01068af:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c01068b2:	77 2b                	ja     c01068df <page_init+0x132>
c01068b4:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c01068b7:	72 05                	jb     c01068be <page_init+0x111>
c01068b9:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c01068bc:	73 21                	jae    c01068df <page_init+0x132>
c01068be:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01068c2:	77 1b                	ja     c01068df <page_init+0x132>
c01068c4:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01068c8:	72 09                	jb     c01068d3 <page_init+0x126>
c01068ca:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c01068d1:	77 0c                	ja     c01068df <page_init+0x132>
                maxpa = end;
c01068d3:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01068d6:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01068d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01068dc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c01068df:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01068e3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01068e6:	8b 00                	mov    (%eax),%eax
c01068e8:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01068eb:	0f 8f f6 fe ff ff    	jg     c01067e7 <page_init+0x3a>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c01068f1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01068f5:	72 1d                	jb     c0106914 <page_init+0x167>
c01068f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01068fb:	77 09                	ja     c0106906 <page_init+0x159>
c01068fd:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0106904:	76 0e                	jbe    c0106914 <page_init+0x167>
        maxpa = KMEMSIZE;
c0106906:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c010690d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0106914:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106917:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010691a:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010691e:	c1 ea 0c             	shr    $0xc,%edx
c0106921:	a3 80 7f 12 c0       	mov    %eax,0xc0127f80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0106926:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c010692d:	b8 64 a1 12 c0       	mov    $0xc012a164,%eax
c0106932:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106935:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0106938:	01 d0                	add    %edx,%eax
c010693a:	89 45 a8             	mov    %eax,-0x58(%ebp)
c010693d:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0106940:	ba 00 00 00 00       	mov    $0x0,%edx
c0106945:	f7 75 ac             	divl   -0x54(%ebp)
c0106948:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010694b:	29 d0                	sub    %edx,%eax
c010694d:	a3 58 a1 12 c0       	mov    %eax,0xc012a158

    for (i = 0; i < npage; i ++) {
c0106952:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0106959:	eb 2f                	jmp    c010698a <page_init+0x1dd>
        SetPageReserved(pages + i);
c010695b:	8b 0d 58 a1 12 c0    	mov    0xc012a158,%ecx
c0106961:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106964:	89 d0                	mov    %edx,%eax
c0106966:	c1 e0 03             	shl    $0x3,%eax
c0106969:	01 d0                	add    %edx,%eax
c010696b:	c1 e0 02             	shl    $0x2,%eax
c010696e:	01 c8                	add    %ecx,%eax
c0106970:	83 c0 04             	add    $0x4,%eax
c0106973:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c010697a:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010697d:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0106980:	8b 55 90             	mov    -0x70(%ebp),%edx
c0106983:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c0106986:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c010698a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010698d:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0106992:	39 c2                	cmp    %eax,%edx
c0106994:	72 c5                	jb     c010695b <page_init+0x1ae>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0106996:	8b 15 80 7f 12 c0    	mov    0xc0127f80,%edx
c010699c:	89 d0                	mov    %edx,%eax
c010699e:	c1 e0 03             	shl    $0x3,%eax
c01069a1:	01 d0                	add    %edx,%eax
c01069a3:	c1 e0 02             	shl    $0x2,%eax
c01069a6:	89 c2                	mov    %eax,%edx
c01069a8:	a1 58 a1 12 c0       	mov    0xc012a158,%eax
c01069ad:	01 d0                	add    %edx,%eax
c01069af:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c01069b2:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c01069b9:	77 17                	ja     c01069d2 <page_init+0x225>
c01069bb:	ff 75 a4             	pushl  -0x5c(%ebp)
c01069be:	68 30 ad 10 c0       	push   $0xc010ad30
c01069c3:	68 ea 00 00 00       	push   $0xea
c01069c8:	68 54 ad 10 c0       	push   $0xc010ad54
c01069cd:	e8 1e 9a ff ff       	call   c01003f0 <__panic>
c01069d2:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01069d5:	05 00 00 00 40       	add    $0x40000000,%eax
c01069da:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c01069dd:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01069e4:	e9 69 01 00 00       	jmp    c0106b52 <page_init+0x3a5>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01069e9:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01069ec:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01069ef:	89 d0                	mov    %edx,%eax
c01069f1:	c1 e0 02             	shl    $0x2,%eax
c01069f4:	01 d0                	add    %edx,%eax
c01069f6:	c1 e0 02             	shl    $0x2,%eax
c01069f9:	01 c8                	add    %ecx,%eax
c01069fb:	8b 50 08             	mov    0x8(%eax),%edx
c01069fe:	8b 40 04             	mov    0x4(%eax),%eax
c0106a01:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106a04:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0106a07:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106a0a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106a0d:	89 d0                	mov    %edx,%eax
c0106a0f:	c1 e0 02             	shl    $0x2,%eax
c0106a12:	01 d0                	add    %edx,%eax
c0106a14:	c1 e0 02             	shl    $0x2,%eax
c0106a17:	01 c8                	add    %ecx,%eax
c0106a19:	8b 48 0c             	mov    0xc(%eax),%ecx
c0106a1c:	8b 58 10             	mov    0x10(%eax),%ebx
c0106a1f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106a22:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106a25:	01 c8                	add    %ecx,%eax
c0106a27:	11 da                	adc    %ebx,%edx
c0106a29:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0106a2c:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0106a2f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106a32:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106a35:	89 d0                	mov    %edx,%eax
c0106a37:	c1 e0 02             	shl    $0x2,%eax
c0106a3a:	01 d0                	add    %edx,%eax
c0106a3c:	c1 e0 02             	shl    $0x2,%eax
c0106a3f:	01 c8                	add    %ecx,%eax
c0106a41:	83 c0 14             	add    $0x14,%eax
c0106a44:	8b 00                	mov    (%eax),%eax
c0106a46:	83 f8 01             	cmp    $0x1,%eax
c0106a49:	0f 85 ff 00 00 00    	jne    c0106b4e <page_init+0x3a1>
            if (begin < freemem) {
c0106a4f:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106a52:	ba 00 00 00 00       	mov    $0x0,%edx
c0106a57:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0106a5a:	72 17                	jb     c0106a73 <page_init+0x2c6>
c0106a5c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0106a5f:	77 05                	ja     c0106a66 <page_init+0x2b9>
c0106a61:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0106a64:	76 0d                	jbe    c0106a73 <page_init+0x2c6>
                begin = freemem;
c0106a66:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106a69:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106a6c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0106a73:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0106a77:	72 1d                	jb     c0106a96 <page_init+0x2e9>
c0106a79:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0106a7d:	77 09                	ja     c0106a88 <page_init+0x2db>
c0106a7f:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0106a86:	76 0e                	jbe    c0106a96 <page_init+0x2e9>
                end = KMEMSIZE;
c0106a88:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0106a8f:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0106a96:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106a99:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106a9c:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0106a9f:	0f 87 a9 00 00 00    	ja     c0106b4e <page_init+0x3a1>
c0106aa5:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0106aa8:	72 09                	jb     c0106ab3 <page_init+0x306>
c0106aaa:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0106aad:	0f 83 9b 00 00 00    	jae    c0106b4e <page_init+0x3a1>
                begin = ROUNDUP(begin, PGSIZE);
c0106ab3:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0106aba:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0106abd:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0106ac0:	01 d0                	add    %edx,%eax
c0106ac2:	83 e8 01             	sub    $0x1,%eax
c0106ac5:	89 45 98             	mov    %eax,-0x68(%ebp)
c0106ac8:	8b 45 98             	mov    -0x68(%ebp),%eax
c0106acb:	ba 00 00 00 00       	mov    $0x0,%edx
c0106ad0:	f7 75 9c             	divl   -0x64(%ebp)
c0106ad3:	8b 45 98             	mov    -0x68(%ebp),%eax
c0106ad6:	29 d0                	sub    %edx,%eax
c0106ad8:	ba 00 00 00 00       	mov    $0x0,%edx
c0106add:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106ae0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0106ae3:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106ae6:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0106ae9:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0106aec:	ba 00 00 00 00       	mov    $0x0,%edx
c0106af1:	89 c3                	mov    %eax,%ebx
c0106af3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0106af9:	89 de                	mov    %ebx,%esi
c0106afb:	89 d0                	mov    %edx,%eax
c0106afd:	83 e0 00             	and    $0x0,%eax
c0106b00:	89 c7                	mov    %eax,%edi
c0106b02:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0106b05:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0106b08:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106b0b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106b0e:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0106b11:	77 3b                	ja     c0106b4e <page_init+0x3a1>
c0106b13:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0106b16:	72 05                	jb     c0106b1d <page_init+0x370>
c0106b18:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0106b1b:	73 31                	jae    c0106b4e <page_init+0x3a1>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0106b1d:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106b20:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0106b23:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0106b26:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0106b29:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0106b2d:	c1 ea 0c             	shr    $0xc,%edx
c0106b30:	89 c3                	mov    %eax,%ebx
c0106b32:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106b35:	83 ec 0c             	sub    $0xc,%esp
c0106b38:	50                   	push   %eax
c0106b39:	e8 b0 f8 ff ff       	call   c01063ee <pa2page>
c0106b3e:	83 c4 10             	add    $0x10,%esp
c0106b41:	83 ec 08             	sub    $0x8,%esp
c0106b44:	53                   	push   %ebx
c0106b45:	50                   	push   %eax
c0106b46:	e8 74 fb ff ff       	call   c01066bf <init_memmap>
c0106b4b:	83 c4 10             	add    $0x10,%esp
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c0106b4e:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0106b52:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106b55:	8b 00                	mov    (%eax),%eax
c0106b57:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0106b5a:	0f 8f 89 fe ff ff    	jg     c01069e9 <page_init+0x23c>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c0106b60:	90                   	nop
c0106b61:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0106b64:	5b                   	pop    %ebx
c0106b65:	5e                   	pop    %esi
c0106b66:	5f                   	pop    %edi
c0106b67:	5d                   	pop    %ebp
c0106b68:	c3                   	ret    

c0106b69 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0106b69:	55                   	push   %ebp
c0106b6a:	89 e5                	mov    %esp,%ebp
c0106b6c:	83 ec 28             	sub    $0x28,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0106b6f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b72:	33 45 14             	xor    0x14(%ebp),%eax
c0106b75:	25 ff 0f 00 00       	and    $0xfff,%eax
c0106b7a:	85 c0                	test   %eax,%eax
c0106b7c:	74 19                	je     c0106b97 <boot_map_segment+0x2e>
c0106b7e:	68 62 ad 10 c0       	push   $0xc010ad62
c0106b83:	68 79 ad 10 c0       	push   $0xc010ad79
c0106b88:	68 08 01 00 00       	push   $0x108
c0106b8d:	68 54 ad 10 c0       	push   $0xc010ad54
c0106b92:	e8 59 98 ff ff       	call   c01003f0 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0106b97:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0106b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106ba1:	25 ff 0f 00 00       	and    $0xfff,%eax
c0106ba6:	89 c2                	mov    %eax,%edx
c0106ba8:	8b 45 10             	mov    0x10(%ebp),%eax
c0106bab:	01 c2                	add    %eax,%edx
c0106bad:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106bb0:	01 d0                	add    %edx,%eax
c0106bb2:	83 e8 01             	sub    $0x1,%eax
c0106bb5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106bb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106bbb:	ba 00 00 00 00       	mov    $0x0,%edx
c0106bc0:	f7 75 f0             	divl   -0x10(%ebp)
c0106bc3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106bc6:	29 d0                	sub    %edx,%eax
c0106bc8:	c1 e8 0c             	shr    $0xc,%eax
c0106bcb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0106bce:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106bd1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106bd4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106bd7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106bdc:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0106bdf:	8b 45 14             	mov    0x14(%ebp),%eax
c0106be2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106be5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106be8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106bed:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0106bf0:	eb 57                	jmp    c0106c49 <boot_map_segment+0xe0>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0106bf2:	83 ec 04             	sub    $0x4,%esp
c0106bf5:	6a 01                	push   $0x1
c0106bf7:	ff 75 0c             	pushl  0xc(%ebp)
c0106bfa:	ff 75 08             	pushl  0x8(%ebp)
c0106bfd:	e8 58 01 00 00       	call   c0106d5a <get_pte>
c0106c02:	83 c4 10             	add    $0x10,%esp
c0106c05:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0106c08:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0106c0c:	75 19                	jne    c0106c27 <boot_map_segment+0xbe>
c0106c0e:	68 8e ad 10 c0       	push   $0xc010ad8e
c0106c13:	68 79 ad 10 c0       	push   $0xc010ad79
c0106c18:	68 0e 01 00 00       	push   $0x10e
c0106c1d:	68 54 ad 10 c0       	push   $0xc010ad54
c0106c22:	e8 c9 97 ff ff       	call   c01003f0 <__panic>
        *ptep = pa | PTE_P | perm;
c0106c27:	8b 45 14             	mov    0x14(%ebp),%eax
c0106c2a:	0b 45 18             	or     0x18(%ebp),%eax
c0106c2d:	83 c8 01             	or     $0x1,%eax
c0106c30:	89 c2                	mov    %eax,%edx
c0106c32:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106c35:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0106c37:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0106c3b:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0106c42:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0106c49:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106c4d:	75 a3                	jne    c0106bf2 <boot_map_segment+0x89>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c0106c4f:	90                   	nop
c0106c50:	c9                   	leave  
c0106c51:	c3                   	ret    

c0106c52 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0106c52:	55                   	push   %ebp
c0106c53:	89 e5                	mov    %esp,%ebp
c0106c55:	83 ec 18             	sub    $0x18,%esp
    struct Page *p = alloc_page();
c0106c58:	83 ec 0c             	sub    $0xc,%esp
c0106c5b:	6a 01                	push   $0x1
c0106c5d:	e8 7c fa ff ff       	call   c01066de <alloc_pages>
c0106c62:	83 c4 10             	add    $0x10,%esp
c0106c65:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0106c68:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106c6c:	75 17                	jne    c0106c85 <boot_alloc_page+0x33>
        panic("boot_alloc_page failed.\n");
c0106c6e:	83 ec 04             	sub    $0x4,%esp
c0106c71:	68 9b ad 10 c0       	push   $0xc010ad9b
c0106c76:	68 1a 01 00 00       	push   $0x11a
c0106c7b:	68 54 ad 10 c0       	push   $0xc010ad54
c0106c80:	e8 6b 97 ff ff       	call   c01003f0 <__panic>
    }
    return page2kva(p);
c0106c85:	83 ec 0c             	sub    $0xc,%esp
c0106c88:	ff 75 f4             	pushl  -0xc(%ebp)
c0106c8b:	e8 a5 f7 ff ff       	call   c0106435 <page2kva>
c0106c90:	83 c4 10             	add    $0x10,%esp
}
c0106c93:	c9                   	leave  
c0106c94:	c3                   	ret    

c0106c95 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0106c95:	55                   	push   %ebp
c0106c96:	89 e5                	mov    %esp,%ebp
c0106c98:	83 ec 18             	sub    $0x18,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0106c9b:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0106ca0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106ca3:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0106caa:	77 17                	ja     c0106cc3 <pmm_init+0x2e>
c0106cac:	ff 75 f4             	pushl  -0xc(%ebp)
c0106caf:	68 30 ad 10 c0       	push   $0xc010ad30
c0106cb4:	68 24 01 00 00       	push   $0x124
c0106cb9:	68 54 ad 10 c0       	push   $0xc010ad54
c0106cbe:	e8 2d 97 ff ff       	call   c01003f0 <__panic>
c0106cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106cc6:	05 00 00 00 40       	add    $0x40000000,%eax
c0106ccb:	a3 54 a1 12 c0       	mov    %eax,0xc012a154
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0106cd0:	e8 b5 f9 ff ff       	call   c010668a <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0106cd5:	e8 d3 fa ff ff       	call   c01067ad <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0106cda:	e8 3d 04 00 00       	call   c010711c <check_alloc_page>

    check_pgdir();
c0106cdf:	e8 5b 04 00 00       	call   c010713f <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0106ce4:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0106ce9:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0106cef:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0106cf4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106cf7:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0106cfe:	77 17                	ja     c0106d17 <pmm_init+0x82>
c0106d00:	ff 75 f0             	pushl  -0x10(%ebp)
c0106d03:	68 30 ad 10 c0       	push   $0xc010ad30
c0106d08:	68 3a 01 00 00       	push   $0x13a
c0106d0d:	68 54 ad 10 c0       	push   $0xc010ad54
c0106d12:	e8 d9 96 ff ff       	call   c01003f0 <__panic>
c0106d17:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106d1a:	05 00 00 00 40       	add    $0x40000000,%eax
c0106d1f:	83 c8 03             	or     $0x3,%eax
c0106d22:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0106d24:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0106d29:	83 ec 0c             	sub    $0xc,%esp
c0106d2c:	6a 02                	push   $0x2
c0106d2e:	6a 00                	push   $0x0
c0106d30:	68 00 00 00 38       	push   $0x38000000
c0106d35:	68 00 00 00 c0       	push   $0xc0000000
c0106d3a:	50                   	push   %eax
c0106d3b:	e8 29 fe ff ff       	call   c0106b69 <boot_map_segment>
c0106d40:	83 c4 20             	add    $0x20,%esp

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0106d43:	e8 50 f8 ff ff       	call   c0106598 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0106d48:	e8 58 09 00 00       	call   c01076a5 <check_boot_pgdir>

    print_pgdir();
c0106d4d:	e8 4e 0d 00 00       	call   c0107aa0 <print_pgdir>
    
    kmalloc_init();
c0106d52:	e8 0c d9 ff ff       	call   c0104663 <kmalloc_init>

}
c0106d57:	90                   	nop
c0106d58:	c9                   	leave  
c0106d59:	c3                   	ret    

c0106d5a <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0106d5a:	55                   	push   %ebp
c0106d5b:	89 e5                	mov    %esp,%ebp
c0106d5d:	83 ec 28             	sub    $0x28,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c0106d60:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106d63:	c1 e8 16             	shr    $0x16,%eax
c0106d66:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106d6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d70:	01 d0                	add    %edx,%eax
c0106d72:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c0106d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d78:	8b 00                	mov    (%eax),%eax
c0106d7a:	83 e0 01             	and    $0x1,%eax
c0106d7d:	85 c0                	test   %eax,%eax
c0106d7f:	0f 85 9f 00 00 00    	jne    c0106e24 <get_pte+0xca>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c0106d85:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106d89:	74 16                	je     c0106da1 <get_pte+0x47>
c0106d8b:	83 ec 0c             	sub    $0xc,%esp
c0106d8e:	6a 01                	push   $0x1
c0106d90:	e8 49 f9 ff ff       	call   c01066de <alloc_pages>
c0106d95:	83 c4 10             	add    $0x10,%esp
c0106d98:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106d9b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106d9f:	75 0a                	jne    c0106dab <get_pte+0x51>
            return NULL;
c0106da1:	b8 00 00 00 00       	mov    $0x0,%eax
c0106da6:	e9 ca 00 00 00       	jmp    c0106e75 <get_pte+0x11b>
        }
        set_page_ref(page, 1);
c0106dab:	83 ec 08             	sub    $0x8,%esp
c0106dae:	6a 01                	push   $0x1
c0106db0:	ff 75 f0             	pushl  -0x10(%ebp)
c0106db3:	e8 22 f7 ff ff       	call   c01064da <set_page_ref>
c0106db8:	83 c4 10             	add    $0x10,%esp
        uintptr_t pa = page2pa(page);
c0106dbb:	83 ec 0c             	sub    $0xc,%esp
c0106dbe:	ff 75 f0             	pushl  -0x10(%ebp)
c0106dc1:	e8 15 f6 ff ff       	call   c01063db <page2pa>
c0106dc6:	83 c4 10             	add    $0x10,%esp
c0106dc9:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c0106dcc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106dcf:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106dd2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106dd5:	c1 e8 0c             	shr    $0xc,%eax
c0106dd8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106ddb:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0106de0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0106de3:	72 17                	jb     c0106dfc <get_pte+0xa2>
c0106de5:	ff 75 e8             	pushl  -0x18(%ebp)
c0106de8:	68 8c ac 10 c0       	push   $0xc010ac8c
c0106ded:	68 82 01 00 00       	push   $0x182
c0106df2:	68 54 ad 10 c0       	push   $0xc010ad54
c0106df7:	e8 f4 95 ff ff       	call   c01003f0 <__panic>
c0106dfc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106dff:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106e04:	83 ec 04             	sub    $0x4,%esp
c0106e07:	68 00 10 00 00       	push   $0x1000
c0106e0c:	6a 00                	push   $0x0
c0106e0e:	50                   	push   %eax
c0106e0f:	e8 f2 1d 00 00       	call   c0108c06 <memset>
c0106e14:	83 c4 10             	add    $0x10,%esp
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0106e17:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106e1a:	83 c8 07             	or     $0x7,%eax
c0106e1d:	89 c2                	mov    %eax,%edx
c0106e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e22:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0106e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e27:	8b 00                	mov    (%eax),%eax
c0106e29:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106e2e:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106e31:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106e34:	c1 e8 0c             	shr    $0xc,%eax
c0106e37:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0106e3a:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0106e3f:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0106e42:	72 17                	jb     c0106e5b <get_pte+0x101>
c0106e44:	ff 75 e0             	pushl  -0x20(%ebp)
c0106e47:	68 8c ac 10 c0       	push   $0xc010ac8c
c0106e4c:	68 85 01 00 00       	push   $0x185
c0106e51:	68 54 ad 10 c0       	push   $0xc010ad54
c0106e56:	e8 95 95 ff ff       	call   c01003f0 <__panic>
c0106e5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106e5e:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106e63:	89 c2                	mov    %eax,%edx
c0106e65:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106e68:	c1 e8 0c             	shr    $0xc,%eax
c0106e6b:	25 ff 03 00 00       	and    $0x3ff,%eax
c0106e70:	c1 e0 02             	shl    $0x2,%eax
c0106e73:	01 d0                	add    %edx,%eax
}
c0106e75:	c9                   	leave  
c0106e76:	c3                   	ret    

c0106e77 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0106e77:	55                   	push   %ebp
c0106e78:	89 e5                	mov    %esp,%ebp
c0106e7a:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0106e7d:	83 ec 04             	sub    $0x4,%esp
c0106e80:	6a 00                	push   $0x0
c0106e82:	ff 75 0c             	pushl  0xc(%ebp)
c0106e85:	ff 75 08             	pushl  0x8(%ebp)
c0106e88:	e8 cd fe ff ff       	call   c0106d5a <get_pte>
c0106e8d:	83 c4 10             	add    $0x10,%esp
c0106e90:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0106e93:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106e97:	74 08                	je     c0106ea1 <get_page+0x2a>
        *ptep_store = ptep;
c0106e99:	8b 45 10             	mov    0x10(%ebp),%eax
c0106e9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106e9f:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0106ea1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106ea5:	74 1f                	je     c0106ec6 <get_page+0x4f>
c0106ea7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106eaa:	8b 00                	mov    (%eax),%eax
c0106eac:	83 e0 01             	and    $0x1,%eax
c0106eaf:	85 c0                	test   %eax,%eax
c0106eb1:	74 13                	je     c0106ec6 <get_page+0x4f>
        return pte2page(*ptep);
c0106eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106eb6:	8b 00                	mov    (%eax),%eax
c0106eb8:	83 ec 0c             	sub    $0xc,%esp
c0106ebb:	50                   	push   %eax
c0106ebc:	e8 b9 f5 ff ff       	call   c010647a <pte2page>
c0106ec1:	83 c4 10             	add    $0x10,%esp
c0106ec4:	eb 05                	jmp    c0106ecb <get_page+0x54>
    }
    return NULL;
c0106ec6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106ecb:	c9                   	leave  
c0106ecc:	c3                   	ret    

c0106ecd <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0106ecd:	55                   	push   %ebp
c0106ece:	89 e5                	mov    %esp,%ebp
c0106ed0:	83 ec 18             	sub    $0x18,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c0106ed3:	8b 45 10             	mov    0x10(%ebp),%eax
c0106ed6:	8b 00                	mov    (%eax),%eax
c0106ed8:	83 e0 01             	and    $0x1,%eax
c0106edb:	85 c0                	test   %eax,%eax
c0106edd:	74 50                	je     c0106f2f <page_remove_pte+0x62>
        struct Page *page = pte2page(*ptep);
c0106edf:	8b 45 10             	mov    0x10(%ebp),%eax
c0106ee2:	8b 00                	mov    (%eax),%eax
c0106ee4:	83 ec 0c             	sub    $0xc,%esp
c0106ee7:	50                   	push   %eax
c0106ee8:	e8 8d f5 ff ff       	call   c010647a <pte2page>
c0106eed:	83 c4 10             	add    $0x10,%esp
c0106ef0:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0106ef3:	83 ec 0c             	sub    $0xc,%esp
c0106ef6:	ff 75 f4             	pushl  -0xc(%ebp)
c0106ef9:	e8 01 f6 ff ff       	call   c01064ff <page_ref_dec>
c0106efe:	83 c4 10             	add    $0x10,%esp
c0106f01:	85 c0                	test   %eax,%eax
c0106f03:	75 10                	jne    c0106f15 <page_remove_pte+0x48>
            free_page(page);
c0106f05:	83 ec 08             	sub    $0x8,%esp
c0106f08:	6a 01                	push   $0x1
c0106f0a:	ff 75 f4             	pushl  -0xc(%ebp)
c0106f0d:	e8 38 f8 ff ff       	call   c010674a <free_pages>
c0106f12:	83 c4 10             	add    $0x10,%esp
        }
        *ptep = 0;
c0106f15:	8b 45 10             	mov    0x10(%ebp),%eax
c0106f18:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0106f1e:	83 ec 08             	sub    $0x8,%esp
c0106f21:	ff 75 0c             	pushl  0xc(%ebp)
c0106f24:	ff 75 08             	pushl  0x8(%ebp)
c0106f27:	e8 f8 00 00 00       	call   c0107024 <tlb_invalidate>
c0106f2c:	83 c4 10             	add    $0x10,%esp
    }
}
c0106f2f:	90                   	nop
c0106f30:	c9                   	leave  
c0106f31:	c3                   	ret    

c0106f32 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0106f32:	55                   	push   %ebp
c0106f33:	89 e5                	mov    %esp,%ebp
c0106f35:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0106f38:	83 ec 04             	sub    $0x4,%esp
c0106f3b:	6a 00                	push   $0x0
c0106f3d:	ff 75 0c             	pushl  0xc(%ebp)
c0106f40:	ff 75 08             	pushl  0x8(%ebp)
c0106f43:	e8 12 fe ff ff       	call   c0106d5a <get_pte>
c0106f48:	83 c4 10             	add    $0x10,%esp
c0106f4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0106f4e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106f52:	74 14                	je     c0106f68 <page_remove+0x36>
        page_remove_pte(pgdir, la, ptep);
c0106f54:	83 ec 04             	sub    $0x4,%esp
c0106f57:	ff 75 f4             	pushl  -0xc(%ebp)
c0106f5a:	ff 75 0c             	pushl  0xc(%ebp)
c0106f5d:	ff 75 08             	pushl  0x8(%ebp)
c0106f60:	e8 68 ff ff ff       	call   c0106ecd <page_remove_pte>
c0106f65:	83 c4 10             	add    $0x10,%esp
    }
}
c0106f68:	90                   	nop
c0106f69:	c9                   	leave  
c0106f6a:	c3                   	ret    

c0106f6b <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0106f6b:	55                   	push   %ebp
c0106f6c:	89 e5                	mov    %esp,%ebp
c0106f6e:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0106f71:	83 ec 04             	sub    $0x4,%esp
c0106f74:	6a 01                	push   $0x1
c0106f76:	ff 75 10             	pushl  0x10(%ebp)
c0106f79:	ff 75 08             	pushl  0x8(%ebp)
c0106f7c:	e8 d9 fd ff ff       	call   c0106d5a <get_pte>
c0106f81:	83 c4 10             	add    $0x10,%esp
c0106f84:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0106f87:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106f8b:	75 0a                	jne    c0106f97 <page_insert+0x2c>
        return -E_NO_MEM;
c0106f8d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0106f92:	e9 8b 00 00 00       	jmp    c0107022 <page_insert+0xb7>
    }
    page_ref_inc(page);
c0106f97:	83 ec 0c             	sub    $0xc,%esp
c0106f9a:	ff 75 0c             	pushl  0xc(%ebp)
c0106f9d:	e8 46 f5 ff ff       	call   c01064e8 <page_ref_inc>
c0106fa2:	83 c4 10             	add    $0x10,%esp
    if (*ptep & PTE_P) {
c0106fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106fa8:	8b 00                	mov    (%eax),%eax
c0106faa:	83 e0 01             	and    $0x1,%eax
c0106fad:	85 c0                	test   %eax,%eax
c0106faf:	74 40                	je     c0106ff1 <page_insert+0x86>
        struct Page *p = pte2page(*ptep);
c0106fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106fb4:	8b 00                	mov    (%eax),%eax
c0106fb6:	83 ec 0c             	sub    $0xc,%esp
c0106fb9:	50                   	push   %eax
c0106fba:	e8 bb f4 ff ff       	call   c010647a <pte2page>
c0106fbf:	83 c4 10             	add    $0x10,%esp
c0106fc2:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0106fc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106fc8:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106fcb:	75 10                	jne    c0106fdd <page_insert+0x72>
            page_ref_dec(page);
c0106fcd:	83 ec 0c             	sub    $0xc,%esp
c0106fd0:	ff 75 0c             	pushl  0xc(%ebp)
c0106fd3:	e8 27 f5 ff ff       	call   c01064ff <page_ref_dec>
c0106fd8:	83 c4 10             	add    $0x10,%esp
c0106fdb:	eb 14                	jmp    c0106ff1 <page_insert+0x86>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0106fdd:	83 ec 04             	sub    $0x4,%esp
c0106fe0:	ff 75 f4             	pushl  -0xc(%ebp)
c0106fe3:	ff 75 10             	pushl  0x10(%ebp)
c0106fe6:	ff 75 08             	pushl  0x8(%ebp)
c0106fe9:	e8 df fe ff ff       	call   c0106ecd <page_remove_pte>
c0106fee:	83 c4 10             	add    $0x10,%esp
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0106ff1:	83 ec 0c             	sub    $0xc,%esp
c0106ff4:	ff 75 0c             	pushl  0xc(%ebp)
c0106ff7:	e8 df f3 ff ff       	call   c01063db <page2pa>
c0106ffc:	83 c4 10             	add    $0x10,%esp
c0106fff:	0b 45 14             	or     0x14(%ebp),%eax
c0107002:	83 c8 01             	or     $0x1,%eax
c0107005:	89 c2                	mov    %eax,%edx
c0107007:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010700a:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c010700c:	83 ec 08             	sub    $0x8,%esp
c010700f:	ff 75 10             	pushl  0x10(%ebp)
c0107012:	ff 75 08             	pushl  0x8(%ebp)
c0107015:	e8 0a 00 00 00       	call   c0107024 <tlb_invalidate>
c010701a:	83 c4 10             	add    $0x10,%esp
    return 0;
c010701d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107022:	c9                   	leave  
c0107023:	c3                   	ret    

c0107024 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0107024:	55                   	push   %ebp
c0107025:	89 e5                	mov    %esp,%ebp
c0107027:	83 ec 18             	sub    $0x18,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c010702a:	0f 20 d8             	mov    %cr3,%eax
c010702d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return cr3;
c0107030:	8b 55 ec             	mov    -0x14(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0107033:	8b 45 08             	mov    0x8(%ebp),%eax
c0107036:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107039:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0107040:	77 17                	ja     c0107059 <tlb_invalidate+0x35>
c0107042:	ff 75 f0             	pushl  -0x10(%ebp)
c0107045:	68 30 ad 10 c0       	push   $0xc010ad30
c010704a:	68 e7 01 00 00       	push   $0x1e7
c010704f:	68 54 ad 10 c0       	push   $0xc010ad54
c0107054:	e8 97 93 ff ff       	call   c01003f0 <__panic>
c0107059:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010705c:	05 00 00 00 40       	add    $0x40000000,%eax
c0107061:	39 c2                	cmp    %eax,%edx
c0107063:	75 0c                	jne    c0107071 <tlb_invalidate+0x4d>
        invlpg((void *)la);
c0107065:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107068:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c010706b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010706e:	0f 01 38             	invlpg (%eax)
    }
}
c0107071:	90                   	nop
c0107072:	c9                   	leave  
c0107073:	c3                   	ret    

c0107074 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c0107074:	55                   	push   %ebp
c0107075:	89 e5                	mov    %esp,%ebp
c0107077:	83 ec 18             	sub    $0x18,%esp
    struct Page *page = alloc_page();
c010707a:	83 ec 0c             	sub    $0xc,%esp
c010707d:	6a 01                	push   $0x1
c010707f:	e8 5a f6 ff ff       	call   c01066de <alloc_pages>
c0107084:	83 c4 10             	add    $0x10,%esp
c0107087:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c010708a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010708e:	0f 84 83 00 00 00    	je     c0107117 <pgdir_alloc_page+0xa3>
        if (page_insert(pgdir, page, la, perm) != 0) {
c0107094:	ff 75 10             	pushl  0x10(%ebp)
c0107097:	ff 75 0c             	pushl  0xc(%ebp)
c010709a:	ff 75 f4             	pushl  -0xc(%ebp)
c010709d:	ff 75 08             	pushl  0x8(%ebp)
c01070a0:	e8 c6 fe ff ff       	call   c0106f6b <page_insert>
c01070a5:	83 c4 10             	add    $0x10,%esp
c01070a8:	85 c0                	test   %eax,%eax
c01070aa:	74 17                	je     c01070c3 <pgdir_alloc_page+0x4f>
            free_page(page);
c01070ac:	83 ec 08             	sub    $0x8,%esp
c01070af:	6a 01                	push   $0x1
c01070b1:	ff 75 f4             	pushl  -0xc(%ebp)
c01070b4:	e8 91 f6 ff ff       	call   c010674a <free_pages>
c01070b9:	83 c4 10             	add    $0x10,%esp
            return NULL;
c01070bc:	b8 00 00 00 00       	mov    $0x0,%eax
c01070c1:	eb 57                	jmp    c010711a <pgdir_alloc_page+0xa6>
        }
        if (swap_init_ok){
c01070c3:	a1 6c 7f 12 c0       	mov    0xc0127f6c,%eax
c01070c8:	85 c0                	test   %eax,%eax
c01070ca:	74 4b                	je     c0107117 <pgdir_alloc_page+0xa3>
            swap_map_swappable(check_mm_struct, la, page, 0);
c01070cc:	a1 58 a0 12 c0       	mov    0xc012a058,%eax
c01070d1:	6a 00                	push   $0x0
c01070d3:	ff 75 f4             	pushl  -0xc(%ebp)
c01070d6:	ff 75 0c             	pushl  0xc(%ebp)
c01070d9:	50                   	push   %eax
c01070da:	e8 69 d9 ff ff       	call   c0104a48 <swap_map_swappable>
c01070df:	83 c4 10             	add    $0x10,%esp
            page->pra_vaddr=la;
c01070e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01070e5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01070e8:	89 50 20             	mov    %edx,0x20(%eax)
            assert(page_ref(page) == 1);
c01070eb:	83 ec 0c             	sub    $0xc,%esp
c01070ee:	ff 75 f4             	pushl  -0xc(%ebp)
c01070f1:	e8 da f3 ff ff       	call   c01064d0 <page_ref>
c01070f6:	83 c4 10             	add    $0x10,%esp
c01070f9:	83 f8 01             	cmp    $0x1,%eax
c01070fc:	74 19                	je     c0107117 <pgdir_alloc_page+0xa3>
c01070fe:	68 b4 ad 10 c0       	push   $0xc010adb4
c0107103:	68 79 ad 10 c0       	push   $0xc010ad79
c0107108:	68 fa 01 00 00       	push   $0x1fa
c010710d:	68 54 ad 10 c0       	push   $0xc010ad54
c0107112:	e8 d9 92 ff ff       	call   c01003f0 <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c0107117:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010711a:	c9                   	leave  
c010711b:	c3                   	ret    

c010711c <check_alloc_page>:

static void
check_alloc_page(void) {
c010711c:	55                   	push   %ebp
c010711d:	89 e5                	mov    %esp,%ebp
c010711f:	83 ec 08             	sub    $0x8,%esp
    pmm_manager->check();
c0107122:	a1 50 a1 12 c0       	mov    0xc012a150,%eax
c0107127:	8b 40 18             	mov    0x18(%eax),%eax
c010712a:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c010712c:	83 ec 0c             	sub    $0xc,%esp
c010712f:	68 c8 ad 10 c0       	push   $0xc010adc8
c0107134:	e8 51 91 ff ff       	call   c010028a <cprintf>
c0107139:	83 c4 10             	add    $0x10,%esp
}
c010713c:	90                   	nop
c010713d:	c9                   	leave  
c010713e:	c3                   	ret    

c010713f <check_pgdir>:

static void
check_pgdir(void) {
c010713f:	55                   	push   %ebp
c0107140:	89 e5                	mov    %esp,%ebp
c0107142:	83 ec 28             	sub    $0x28,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0107145:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c010714a:	3d 00 80 03 00       	cmp    $0x38000,%eax
c010714f:	76 19                	jbe    c010716a <check_pgdir+0x2b>
c0107151:	68 e7 ad 10 c0       	push   $0xc010ade7
c0107156:	68 79 ad 10 c0       	push   $0xc010ad79
c010715b:	68 0b 02 00 00       	push   $0x20b
c0107160:	68 54 ad 10 c0       	push   $0xc010ad54
c0107165:	e8 86 92 ff ff       	call   c01003f0 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c010716a:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c010716f:	85 c0                	test   %eax,%eax
c0107171:	74 0e                	je     c0107181 <check_pgdir+0x42>
c0107173:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107178:	25 ff 0f 00 00       	and    $0xfff,%eax
c010717d:	85 c0                	test   %eax,%eax
c010717f:	74 19                	je     c010719a <check_pgdir+0x5b>
c0107181:	68 04 ae 10 c0       	push   $0xc010ae04
c0107186:	68 79 ad 10 c0       	push   $0xc010ad79
c010718b:	68 0c 02 00 00       	push   $0x20c
c0107190:	68 54 ad 10 c0       	push   $0xc010ad54
c0107195:	e8 56 92 ff ff       	call   c01003f0 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c010719a:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c010719f:	83 ec 04             	sub    $0x4,%esp
c01071a2:	6a 00                	push   $0x0
c01071a4:	6a 00                	push   $0x0
c01071a6:	50                   	push   %eax
c01071a7:	e8 cb fc ff ff       	call   c0106e77 <get_page>
c01071ac:	83 c4 10             	add    $0x10,%esp
c01071af:	85 c0                	test   %eax,%eax
c01071b1:	74 19                	je     c01071cc <check_pgdir+0x8d>
c01071b3:	68 3c ae 10 c0       	push   $0xc010ae3c
c01071b8:	68 79 ad 10 c0       	push   $0xc010ad79
c01071bd:	68 0d 02 00 00       	push   $0x20d
c01071c2:	68 54 ad 10 c0       	push   $0xc010ad54
c01071c7:	e8 24 92 ff ff       	call   c01003f0 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01071cc:	83 ec 0c             	sub    $0xc,%esp
c01071cf:	6a 01                	push   $0x1
c01071d1:	e8 08 f5 ff ff       	call   c01066de <alloc_pages>
c01071d6:	83 c4 10             	add    $0x10,%esp
c01071d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01071dc:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c01071e1:	6a 00                	push   $0x0
c01071e3:	6a 00                	push   $0x0
c01071e5:	ff 75 f4             	pushl  -0xc(%ebp)
c01071e8:	50                   	push   %eax
c01071e9:	e8 7d fd ff ff       	call   c0106f6b <page_insert>
c01071ee:	83 c4 10             	add    $0x10,%esp
c01071f1:	85 c0                	test   %eax,%eax
c01071f3:	74 19                	je     c010720e <check_pgdir+0xcf>
c01071f5:	68 64 ae 10 c0       	push   $0xc010ae64
c01071fa:	68 79 ad 10 c0       	push   $0xc010ad79
c01071ff:	68 11 02 00 00       	push   $0x211
c0107204:	68 54 ad 10 c0       	push   $0xc010ad54
c0107209:	e8 e2 91 ff ff       	call   c01003f0 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c010720e:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107213:	83 ec 04             	sub    $0x4,%esp
c0107216:	6a 00                	push   $0x0
c0107218:	6a 00                	push   $0x0
c010721a:	50                   	push   %eax
c010721b:	e8 3a fb ff ff       	call   c0106d5a <get_pte>
c0107220:	83 c4 10             	add    $0x10,%esp
c0107223:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107226:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010722a:	75 19                	jne    c0107245 <check_pgdir+0x106>
c010722c:	68 90 ae 10 c0       	push   $0xc010ae90
c0107231:	68 79 ad 10 c0       	push   $0xc010ad79
c0107236:	68 14 02 00 00       	push   $0x214
c010723b:	68 54 ad 10 c0       	push   $0xc010ad54
c0107240:	e8 ab 91 ff ff       	call   c01003f0 <__panic>
    assert(pte2page(*ptep) == p1);
c0107245:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107248:	8b 00                	mov    (%eax),%eax
c010724a:	83 ec 0c             	sub    $0xc,%esp
c010724d:	50                   	push   %eax
c010724e:	e8 27 f2 ff ff       	call   c010647a <pte2page>
c0107253:	83 c4 10             	add    $0x10,%esp
c0107256:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0107259:	74 19                	je     c0107274 <check_pgdir+0x135>
c010725b:	68 bd ae 10 c0       	push   $0xc010aebd
c0107260:	68 79 ad 10 c0       	push   $0xc010ad79
c0107265:	68 15 02 00 00       	push   $0x215
c010726a:	68 54 ad 10 c0       	push   $0xc010ad54
c010726f:	e8 7c 91 ff ff       	call   c01003f0 <__panic>
    assert(page_ref(p1) == 1);
c0107274:	83 ec 0c             	sub    $0xc,%esp
c0107277:	ff 75 f4             	pushl  -0xc(%ebp)
c010727a:	e8 51 f2 ff ff       	call   c01064d0 <page_ref>
c010727f:	83 c4 10             	add    $0x10,%esp
c0107282:	83 f8 01             	cmp    $0x1,%eax
c0107285:	74 19                	je     c01072a0 <check_pgdir+0x161>
c0107287:	68 d3 ae 10 c0       	push   $0xc010aed3
c010728c:	68 79 ad 10 c0       	push   $0xc010ad79
c0107291:	68 16 02 00 00       	push   $0x216
c0107296:	68 54 ad 10 c0       	push   $0xc010ad54
c010729b:	e8 50 91 ff ff       	call   c01003f0 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01072a0:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c01072a5:	8b 00                	mov    (%eax),%eax
c01072a7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01072ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01072af:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01072b2:	c1 e8 0c             	shr    $0xc,%eax
c01072b5:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01072b8:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c01072bd:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01072c0:	72 17                	jb     c01072d9 <check_pgdir+0x19a>
c01072c2:	ff 75 ec             	pushl  -0x14(%ebp)
c01072c5:	68 8c ac 10 c0       	push   $0xc010ac8c
c01072ca:	68 18 02 00 00       	push   $0x218
c01072cf:	68 54 ad 10 c0       	push   $0xc010ad54
c01072d4:	e8 17 91 ff ff       	call   c01003f0 <__panic>
c01072d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01072dc:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01072e1:	83 c0 04             	add    $0x4,%eax
c01072e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c01072e7:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c01072ec:	83 ec 04             	sub    $0x4,%esp
c01072ef:	6a 00                	push   $0x0
c01072f1:	68 00 10 00 00       	push   $0x1000
c01072f6:	50                   	push   %eax
c01072f7:	e8 5e fa ff ff       	call   c0106d5a <get_pte>
c01072fc:	83 c4 10             	add    $0x10,%esp
c01072ff:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107302:	74 19                	je     c010731d <check_pgdir+0x1de>
c0107304:	68 e8 ae 10 c0       	push   $0xc010aee8
c0107309:	68 79 ad 10 c0       	push   $0xc010ad79
c010730e:	68 19 02 00 00       	push   $0x219
c0107313:	68 54 ad 10 c0       	push   $0xc010ad54
c0107318:	e8 d3 90 ff ff       	call   c01003f0 <__panic>

    p2 = alloc_page();
c010731d:	83 ec 0c             	sub    $0xc,%esp
c0107320:	6a 01                	push   $0x1
c0107322:	e8 b7 f3 ff ff       	call   c01066de <alloc_pages>
c0107327:	83 c4 10             	add    $0x10,%esp
c010732a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c010732d:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107332:	6a 06                	push   $0x6
c0107334:	68 00 10 00 00       	push   $0x1000
c0107339:	ff 75 e4             	pushl  -0x1c(%ebp)
c010733c:	50                   	push   %eax
c010733d:	e8 29 fc ff ff       	call   c0106f6b <page_insert>
c0107342:	83 c4 10             	add    $0x10,%esp
c0107345:	85 c0                	test   %eax,%eax
c0107347:	74 19                	je     c0107362 <check_pgdir+0x223>
c0107349:	68 10 af 10 c0       	push   $0xc010af10
c010734e:	68 79 ad 10 c0       	push   $0xc010ad79
c0107353:	68 1c 02 00 00       	push   $0x21c
c0107358:	68 54 ad 10 c0       	push   $0xc010ad54
c010735d:	e8 8e 90 ff ff       	call   c01003f0 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0107362:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107367:	83 ec 04             	sub    $0x4,%esp
c010736a:	6a 00                	push   $0x0
c010736c:	68 00 10 00 00       	push   $0x1000
c0107371:	50                   	push   %eax
c0107372:	e8 e3 f9 ff ff       	call   c0106d5a <get_pte>
c0107377:	83 c4 10             	add    $0x10,%esp
c010737a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010737d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107381:	75 19                	jne    c010739c <check_pgdir+0x25d>
c0107383:	68 48 af 10 c0       	push   $0xc010af48
c0107388:	68 79 ad 10 c0       	push   $0xc010ad79
c010738d:	68 1d 02 00 00       	push   $0x21d
c0107392:	68 54 ad 10 c0       	push   $0xc010ad54
c0107397:	e8 54 90 ff ff       	call   c01003f0 <__panic>
    assert(*ptep & PTE_U);
c010739c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010739f:	8b 00                	mov    (%eax),%eax
c01073a1:	83 e0 04             	and    $0x4,%eax
c01073a4:	85 c0                	test   %eax,%eax
c01073a6:	75 19                	jne    c01073c1 <check_pgdir+0x282>
c01073a8:	68 78 af 10 c0       	push   $0xc010af78
c01073ad:	68 79 ad 10 c0       	push   $0xc010ad79
c01073b2:	68 1e 02 00 00       	push   $0x21e
c01073b7:	68 54 ad 10 c0       	push   $0xc010ad54
c01073bc:	e8 2f 90 ff ff       	call   c01003f0 <__panic>
    assert(*ptep & PTE_W);
c01073c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01073c4:	8b 00                	mov    (%eax),%eax
c01073c6:	83 e0 02             	and    $0x2,%eax
c01073c9:	85 c0                	test   %eax,%eax
c01073cb:	75 19                	jne    c01073e6 <check_pgdir+0x2a7>
c01073cd:	68 86 af 10 c0       	push   $0xc010af86
c01073d2:	68 79 ad 10 c0       	push   $0xc010ad79
c01073d7:	68 1f 02 00 00       	push   $0x21f
c01073dc:	68 54 ad 10 c0       	push   $0xc010ad54
c01073e1:	e8 0a 90 ff ff       	call   c01003f0 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c01073e6:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c01073eb:	8b 00                	mov    (%eax),%eax
c01073ed:	83 e0 04             	and    $0x4,%eax
c01073f0:	85 c0                	test   %eax,%eax
c01073f2:	75 19                	jne    c010740d <check_pgdir+0x2ce>
c01073f4:	68 94 af 10 c0       	push   $0xc010af94
c01073f9:	68 79 ad 10 c0       	push   $0xc010ad79
c01073fe:	68 20 02 00 00       	push   $0x220
c0107403:	68 54 ad 10 c0       	push   $0xc010ad54
c0107408:	e8 e3 8f ff ff       	call   c01003f0 <__panic>
    assert(page_ref(p2) == 1);
c010740d:	83 ec 0c             	sub    $0xc,%esp
c0107410:	ff 75 e4             	pushl  -0x1c(%ebp)
c0107413:	e8 b8 f0 ff ff       	call   c01064d0 <page_ref>
c0107418:	83 c4 10             	add    $0x10,%esp
c010741b:	83 f8 01             	cmp    $0x1,%eax
c010741e:	74 19                	je     c0107439 <check_pgdir+0x2fa>
c0107420:	68 aa af 10 c0       	push   $0xc010afaa
c0107425:	68 79 ad 10 c0       	push   $0xc010ad79
c010742a:	68 21 02 00 00       	push   $0x221
c010742f:	68 54 ad 10 c0       	push   $0xc010ad54
c0107434:	e8 b7 8f ff ff       	call   c01003f0 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0107439:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c010743e:	6a 00                	push   $0x0
c0107440:	68 00 10 00 00       	push   $0x1000
c0107445:	ff 75 f4             	pushl  -0xc(%ebp)
c0107448:	50                   	push   %eax
c0107449:	e8 1d fb ff ff       	call   c0106f6b <page_insert>
c010744e:	83 c4 10             	add    $0x10,%esp
c0107451:	85 c0                	test   %eax,%eax
c0107453:	74 19                	je     c010746e <check_pgdir+0x32f>
c0107455:	68 bc af 10 c0       	push   $0xc010afbc
c010745a:	68 79 ad 10 c0       	push   $0xc010ad79
c010745f:	68 23 02 00 00       	push   $0x223
c0107464:	68 54 ad 10 c0       	push   $0xc010ad54
c0107469:	e8 82 8f ff ff       	call   c01003f0 <__panic>
    assert(page_ref(p1) == 2);
c010746e:	83 ec 0c             	sub    $0xc,%esp
c0107471:	ff 75 f4             	pushl  -0xc(%ebp)
c0107474:	e8 57 f0 ff ff       	call   c01064d0 <page_ref>
c0107479:	83 c4 10             	add    $0x10,%esp
c010747c:	83 f8 02             	cmp    $0x2,%eax
c010747f:	74 19                	je     c010749a <check_pgdir+0x35b>
c0107481:	68 e8 af 10 c0       	push   $0xc010afe8
c0107486:	68 79 ad 10 c0       	push   $0xc010ad79
c010748b:	68 24 02 00 00       	push   $0x224
c0107490:	68 54 ad 10 c0       	push   $0xc010ad54
c0107495:	e8 56 8f ff ff       	call   c01003f0 <__panic>
    assert(page_ref(p2) == 0);
c010749a:	83 ec 0c             	sub    $0xc,%esp
c010749d:	ff 75 e4             	pushl  -0x1c(%ebp)
c01074a0:	e8 2b f0 ff ff       	call   c01064d0 <page_ref>
c01074a5:	83 c4 10             	add    $0x10,%esp
c01074a8:	85 c0                	test   %eax,%eax
c01074aa:	74 19                	je     c01074c5 <check_pgdir+0x386>
c01074ac:	68 fa af 10 c0       	push   $0xc010affa
c01074b1:	68 79 ad 10 c0       	push   $0xc010ad79
c01074b6:	68 25 02 00 00       	push   $0x225
c01074bb:	68 54 ad 10 c0       	push   $0xc010ad54
c01074c0:	e8 2b 8f ff ff       	call   c01003f0 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01074c5:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c01074ca:	83 ec 04             	sub    $0x4,%esp
c01074cd:	6a 00                	push   $0x0
c01074cf:	68 00 10 00 00       	push   $0x1000
c01074d4:	50                   	push   %eax
c01074d5:	e8 80 f8 ff ff       	call   c0106d5a <get_pte>
c01074da:	83 c4 10             	add    $0x10,%esp
c01074dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01074e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01074e4:	75 19                	jne    c01074ff <check_pgdir+0x3c0>
c01074e6:	68 48 af 10 c0       	push   $0xc010af48
c01074eb:	68 79 ad 10 c0       	push   $0xc010ad79
c01074f0:	68 26 02 00 00       	push   $0x226
c01074f5:	68 54 ad 10 c0       	push   $0xc010ad54
c01074fa:	e8 f1 8e ff ff       	call   c01003f0 <__panic>
    assert(pte2page(*ptep) == p1);
c01074ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107502:	8b 00                	mov    (%eax),%eax
c0107504:	83 ec 0c             	sub    $0xc,%esp
c0107507:	50                   	push   %eax
c0107508:	e8 6d ef ff ff       	call   c010647a <pte2page>
c010750d:	83 c4 10             	add    $0x10,%esp
c0107510:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0107513:	74 19                	je     c010752e <check_pgdir+0x3ef>
c0107515:	68 bd ae 10 c0       	push   $0xc010aebd
c010751a:	68 79 ad 10 c0       	push   $0xc010ad79
c010751f:	68 27 02 00 00       	push   $0x227
c0107524:	68 54 ad 10 c0       	push   $0xc010ad54
c0107529:	e8 c2 8e ff ff       	call   c01003f0 <__panic>
    assert((*ptep & PTE_U) == 0);
c010752e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107531:	8b 00                	mov    (%eax),%eax
c0107533:	83 e0 04             	and    $0x4,%eax
c0107536:	85 c0                	test   %eax,%eax
c0107538:	74 19                	je     c0107553 <check_pgdir+0x414>
c010753a:	68 0c b0 10 c0       	push   $0xc010b00c
c010753f:	68 79 ad 10 c0       	push   $0xc010ad79
c0107544:	68 28 02 00 00       	push   $0x228
c0107549:	68 54 ad 10 c0       	push   $0xc010ad54
c010754e:	e8 9d 8e ff ff       	call   c01003f0 <__panic>

    page_remove(boot_pgdir, 0x0);
c0107553:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107558:	83 ec 08             	sub    $0x8,%esp
c010755b:	6a 00                	push   $0x0
c010755d:	50                   	push   %eax
c010755e:	e8 cf f9 ff ff       	call   c0106f32 <page_remove>
c0107563:	83 c4 10             	add    $0x10,%esp
    assert(page_ref(p1) == 1);
c0107566:	83 ec 0c             	sub    $0xc,%esp
c0107569:	ff 75 f4             	pushl  -0xc(%ebp)
c010756c:	e8 5f ef ff ff       	call   c01064d0 <page_ref>
c0107571:	83 c4 10             	add    $0x10,%esp
c0107574:	83 f8 01             	cmp    $0x1,%eax
c0107577:	74 19                	je     c0107592 <check_pgdir+0x453>
c0107579:	68 d3 ae 10 c0       	push   $0xc010aed3
c010757e:	68 79 ad 10 c0       	push   $0xc010ad79
c0107583:	68 2b 02 00 00       	push   $0x22b
c0107588:	68 54 ad 10 c0       	push   $0xc010ad54
c010758d:	e8 5e 8e ff ff       	call   c01003f0 <__panic>
    assert(page_ref(p2) == 0);
c0107592:	83 ec 0c             	sub    $0xc,%esp
c0107595:	ff 75 e4             	pushl  -0x1c(%ebp)
c0107598:	e8 33 ef ff ff       	call   c01064d0 <page_ref>
c010759d:	83 c4 10             	add    $0x10,%esp
c01075a0:	85 c0                	test   %eax,%eax
c01075a2:	74 19                	je     c01075bd <check_pgdir+0x47e>
c01075a4:	68 fa af 10 c0       	push   $0xc010affa
c01075a9:	68 79 ad 10 c0       	push   $0xc010ad79
c01075ae:	68 2c 02 00 00       	push   $0x22c
c01075b3:	68 54 ad 10 c0       	push   $0xc010ad54
c01075b8:	e8 33 8e ff ff       	call   c01003f0 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c01075bd:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c01075c2:	83 ec 08             	sub    $0x8,%esp
c01075c5:	68 00 10 00 00       	push   $0x1000
c01075ca:	50                   	push   %eax
c01075cb:	e8 62 f9 ff ff       	call   c0106f32 <page_remove>
c01075d0:	83 c4 10             	add    $0x10,%esp
    assert(page_ref(p1) == 0);
c01075d3:	83 ec 0c             	sub    $0xc,%esp
c01075d6:	ff 75 f4             	pushl  -0xc(%ebp)
c01075d9:	e8 f2 ee ff ff       	call   c01064d0 <page_ref>
c01075de:	83 c4 10             	add    $0x10,%esp
c01075e1:	85 c0                	test   %eax,%eax
c01075e3:	74 19                	je     c01075fe <check_pgdir+0x4bf>
c01075e5:	68 21 b0 10 c0       	push   $0xc010b021
c01075ea:	68 79 ad 10 c0       	push   $0xc010ad79
c01075ef:	68 2f 02 00 00       	push   $0x22f
c01075f4:	68 54 ad 10 c0       	push   $0xc010ad54
c01075f9:	e8 f2 8d ff ff       	call   c01003f0 <__panic>
    assert(page_ref(p2) == 0);
c01075fe:	83 ec 0c             	sub    $0xc,%esp
c0107601:	ff 75 e4             	pushl  -0x1c(%ebp)
c0107604:	e8 c7 ee ff ff       	call   c01064d0 <page_ref>
c0107609:	83 c4 10             	add    $0x10,%esp
c010760c:	85 c0                	test   %eax,%eax
c010760e:	74 19                	je     c0107629 <check_pgdir+0x4ea>
c0107610:	68 fa af 10 c0       	push   $0xc010affa
c0107615:	68 79 ad 10 c0       	push   $0xc010ad79
c010761a:	68 30 02 00 00       	push   $0x230
c010761f:	68 54 ad 10 c0       	push   $0xc010ad54
c0107624:	e8 c7 8d ff ff       	call   c01003f0 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0107629:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c010762e:	8b 00                	mov    (%eax),%eax
c0107630:	83 ec 0c             	sub    $0xc,%esp
c0107633:	50                   	push   %eax
c0107634:	e8 7b ee ff ff       	call   c01064b4 <pde2page>
c0107639:	83 c4 10             	add    $0x10,%esp
c010763c:	83 ec 0c             	sub    $0xc,%esp
c010763f:	50                   	push   %eax
c0107640:	e8 8b ee ff ff       	call   c01064d0 <page_ref>
c0107645:	83 c4 10             	add    $0x10,%esp
c0107648:	83 f8 01             	cmp    $0x1,%eax
c010764b:	74 19                	je     c0107666 <check_pgdir+0x527>
c010764d:	68 34 b0 10 c0       	push   $0xc010b034
c0107652:	68 79 ad 10 c0       	push   $0xc010ad79
c0107657:	68 32 02 00 00       	push   $0x232
c010765c:	68 54 ad 10 c0       	push   $0xc010ad54
c0107661:	e8 8a 8d ff ff       	call   c01003f0 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0107666:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c010766b:	8b 00                	mov    (%eax),%eax
c010766d:	83 ec 0c             	sub    $0xc,%esp
c0107670:	50                   	push   %eax
c0107671:	e8 3e ee ff ff       	call   c01064b4 <pde2page>
c0107676:	83 c4 10             	add    $0x10,%esp
c0107679:	83 ec 08             	sub    $0x8,%esp
c010767c:	6a 01                	push   $0x1
c010767e:	50                   	push   %eax
c010767f:	e8 c6 f0 ff ff       	call   c010674a <free_pages>
c0107684:	83 c4 10             	add    $0x10,%esp
    boot_pgdir[0] = 0;
c0107687:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c010768c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0107692:	83 ec 0c             	sub    $0xc,%esp
c0107695:	68 5b b0 10 c0       	push   $0xc010b05b
c010769a:	e8 eb 8b ff ff       	call   c010028a <cprintf>
c010769f:	83 c4 10             	add    $0x10,%esp
}
c01076a2:	90                   	nop
c01076a3:	c9                   	leave  
c01076a4:	c3                   	ret    

c01076a5 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c01076a5:	55                   	push   %ebp
c01076a6:	89 e5                	mov    %esp,%ebp
c01076a8:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01076ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01076b2:	e9 a3 00 00 00       	jmp    c010775a <check_boot_pgdir+0xb5>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c01076b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01076bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01076c0:	c1 e8 0c             	shr    $0xc,%eax
c01076c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01076c6:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c01076cb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01076ce:	72 17                	jb     c01076e7 <check_boot_pgdir+0x42>
c01076d0:	ff 75 f0             	pushl  -0x10(%ebp)
c01076d3:	68 8c ac 10 c0       	push   $0xc010ac8c
c01076d8:	68 3e 02 00 00       	push   $0x23e
c01076dd:	68 54 ad 10 c0       	push   $0xc010ad54
c01076e2:	e8 09 8d ff ff       	call   c01003f0 <__panic>
c01076e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01076ea:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01076ef:	89 c2                	mov    %eax,%edx
c01076f1:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c01076f6:	83 ec 04             	sub    $0x4,%esp
c01076f9:	6a 00                	push   $0x0
c01076fb:	52                   	push   %edx
c01076fc:	50                   	push   %eax
c01076fd:	e8 58 f6 ff ff       	call   c0106d5a <get_pte>
c0107702:	83 c4 10             	add    $0x10,%esp
c0107705:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107708:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010770c:	75 19                	jne    c0107727 <check_boot_pgdir+0x82>
c010770e:	68 78 b0 10 c0       	push   $0xc010b078
c0107713:	68 79 ad 10 c0       	push   $0xc010ad79
c0107718:	68 3e 02 00 00       	push   $0x23e
c010771d:	68 54 ad 10 c0       	push   $0xc010ad54
c0107722:	e8 c9 8c ff ff       	call   c01003f0 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0107727:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010772a:	8b 00                	mov    (%eax),%eax
c010772c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107731:	89 c2                	mov    %eax,%edx
c0107733:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107736:	39 c2                	cmp    %eax,%edx
c0107738:	74 19                	je     c0107753 <check_boot_pgdir+0xae>
c010773a:	68 b5 b0 10 c0       	push   $0xc010b0b5
c010773f:	68 79 ad 10 c0       	push   $0xc010ad79
c0107744:	68 3f 02 00 00       	push   $0x23f
c0107749:	68 54 ad 10 c0       	push   $0xc010ad54
c010774e:	e8 9d 8c ff ff       	call   c01003f0 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0107753:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c010775a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010775d:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0107762:	39 c2                	cmp    %eax,%edx
c0107764:	0f 82 4d ff ff ff    	jb     c01076b7 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c010776a:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c010776f:	05 ac 0f 00 00       	add    $0xfac,%eax
c0107774:	8b 00                	mov    (%eax),%eax
c0107776:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010777b:	89 c2                	mov    %eax,%edx
c010777d:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107782:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107785:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c010778c:	77 17                	ja     c01077a5 <check_boot_pgdir+0x100>
c010778e:	ff 75 e4             	pushl  -0x1c(%ebp)
c0107791:	68 30 ad 10 c0       	push   $0xc010ad30
c0107796:	68 42 02 00 00       	push   $0x242
c010779b:	68 54 ad 10 c0       	push   $0xc010ad54
c01077a0:	e8 4b 8c ff ff       	call   c01003f0 <__panic>
c01077a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01077a8:	05 00 00 00 40       	add    $0x40000000,%eax
c01077ad:	39 c2                	cmp    %eax,%edx
c01077af:	74 19                	je     c01077ca <check_boot_pgdir+0x125>
c01077b1:	68 cc b0 10 c0       	push   $0xc010b0cc
c01077b6:	68 79 ad 10 c0       	push   $0xc010ad79
c01077bb:	68 42 02 00 00       	push   $0x242
c01077c0:	68 54 ad 10 c0       	push   $0xc010ad54
c01077c5:	e8 26 8c ff ff       	call   c01003f0 <__panic>

    assert(boot_pgdir[0] == 0);
c01077ca:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c01077cf:	8b 00                	mov    (%eax),%eax
c01077d1:	85 c0                	test   %eax,%eax
c01077d3:	74 19                	je     c01077ee <check_boot_pgdir+0x149>
c01077d5:	68 00 b1 10 c0       	push   $0xc010b100
c01077da:	68 79 ad 10 c0       	push   $0xc010ad79
c01077df:	68 44 02 00 00       	push   $0x244
c01077e4:	68 54 ad 10 c0       	push   $0xc010ad54
c01077e9:	e8 02 8c ff ff       	call   c01003f0 <__panic>

    struct Page *p;
    p = alloc_page();
c01077ee:	83 ec 0c             	sub    $0xc,%esp
c01077f1:	6a 01                	push   $0x1
c01077f3:	e8 e6 ee ff ff       	call   c01066de <alloc_pages>
c01077f8:	83 c4 10             	add    $0x10,%esp
c01077fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c01077fe:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107803:	6a 02                	push   $0x2
c0107805:	68 00 01 00 00       	push   $0x100
c010780a:	ff 75 e0             	pushl  -0x20(%ebp)
c010780d:	50                   	push   %eax
c010780e:	e8 58 f7 ff ff       	call   c0106f6b <page_insert>
c0107813:	83 c4 10             	add    $0x10,%esp
c0107816:	85 c0                	test   %eax,%eax
c0107818:	74 19                	je     c0107833 <check_boot_pgdir+0x18e>
c010781a:	68 14 b1 10 c0       	push   $0xc010b114
c010781f:	68 79 ad 10 c0       	push   $0xc010ad79
c0107824:	68 48 02 00 00       	push   $0x248
c0107829:	68 54 ad 10 c0       	push   $0xc010ad54
c010782e:	e8 bd 8b ff ff       	call   c01003f0 <__panic>
    assert(page_ref(p) == 1);
c0107833:	83 ec 0c             	sub    $0xc,%esp
c0107836:	ff 75 e0             	pushl  -0x20(%ebp)
c0107839:	e8 92 ec ff ff       	call   c01064d0 <page_ref>
c010783e:	83 c4 10             	add    $0x10,%esp
c0107841:	83 f8 01             	cmp    $0x1,%eax
c0107844:	74 19                	je     c010785f <check_boot_pgdir+0x1ba>
c0107846:	68 42 b1 10 c0       	push   $0xc010b142
c010784b:	68 79 ad 10 c0       	push   $0xc010ad79
c0107850:	68 49 02 00 00       	push   $0x249
c0107855:	68 54 ad 10 c0       	push   $0xc010ad54
c010785a:	e8 91 8b ff ff       	call   c01003f0 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c010785f:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107864:	6a 02                	push   $0x2
c0107866:	68 00 11 00 00       	push   $0x1100
c010786b:	ff 75 e0             	pushl  -0x20(%ebp)
c010786e:	50                   	push   %eax
c010786f:	e8 f7 f6 ff ff       	call   c0106f6b <page_insert>
c0107874:	83 c4 10             	add    $0x10,%esp
c0107877:	85 c0                	test   %eax,%eax
c0107879:	74 19                	je     c0107894 <check_boot_pgdir+0x1ef>
c010787b:	68 54 b1 10 c0       	push   $0xc010b154
c0107880:	68 79 ad 10 c0       	push   $0xc010ad79
c0107885:	68 4a 02 00 00       	push   $0x24a
c010788a:	68 54 ad 10 c0       	push   $0xc010ad54
c010788f:	e8 5c 8b ff ff       	call   c01003f0 <__panic>
    assert(page_ref(p) == 2);
c0107894:	83 ec 0c             	sub    $0xc,%esp
c0107897:	ff 75 e0             	pushl  -0x20(%ebp)
c010789a:	e8 31 ec ff ff       	call   c01064d0 <page_ref>
c010789f:	83 c4 10             	add    $0x10,%esp
c01078a2:	83 f8 02             	cmp    $0x2,%eax
c01078a5:	74 19                	je     c01078c0 <check_boot_pgdir+0x21b>
c01078a7:	68 8b b1 10 c0       	push   $0xc010b18b
c01078ac:	68 79 ad 10 c0       	push   $0xc010ad79
c01078b1:	68 4b 02 00 00       	push   $0x24b
c01078b6:	68 54 ad 10 c0       	push   $0xc010ad54
c01078bb:	e8 30 8b ff ff       	call   c01003f0 <__panic>

    const char *str = "ucore: Hello world!!";
c01078c0:	c7 45 dc 9c b1 10 c0 	movl   $0xc010b19c,-0x24(%ebp)
    strcpy((void *)0x100, str);
c01078c7:	83 ec 08             	sub    $0x8,%esp
c01078ca:	ff 75 dc             	pushl  -0x24(%ebp)
c01078cd:	68 00 01 00 00       	push   $0x100
c01078d2:	e8 56 10 00 00       	call   c010892d <strcpy>
c01078d7:	83 c4 10             	add    $0x10,%esp
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c01078da:	83 ec 08             	sub    $0x8,%esp
c01078dd:	68 00 11 00 00       	push   $0x1100
c01078e2:	68 00 01 00 00       	push   $0x100
c01078e7:	e8 bb 10 00 00       	call   c01089a7 <strcmp>
c01078ec:	83 c4 10             	add    $0x10,%esp
c01078ef:	85 c0                	test   %eax,%eax
c01078f1:	74 19                	je     c010790c <check_boot_pgdir+0x267>
c01078f3:	68 b4 b1 10 c0       	push   $0xc010b1b4
c01078f8:	68 79 ad 10 c0       	push   $0xc010ad79
c01078fd:	68 4f 02 00 00       	push   $0x24f
c0107902:	68 54 ad 10 c0       	push   $0xc010ad54
c0107907:	e8 e4 8a ff ff       	call   c01003f0 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c010790c:	83 ec 0c             	sub    $0xc,%esp
c010790f:	ff 75 e0             	pushl  -0x20(%ebp)
c0107912:	e8 1e eb ff ff       	call   c0106435 <page2kva>
c0107917:	83 c4 10             	add    $0x10,%esp
c010791a:	05 00 01 00 00       	add    $0x100,%eax
c010791f:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0107922:	83 ec 0c             	sub    $0xc,%esp
c0107925:	68 00 01 00 00       	push   $0x100
c010792a:	e8 a6 0f 00 00       	call   c01088d5 <strlen>
c010792f:	83 c4 10             	add    $0x10,%esp
c0107932:	85 c0                	test   %eax,%eax
c0107934:	74 19                	je     c010794f <check_boot_pgdir+0x2aa>
c0107936:	68 ec b1 10 c0       	push   $0xc010b1ec
c010793b:	68 79 ad 10 c0       	push   $0xc010ad79
c0107940:	68 52 02 00 00       	push   $0x252
c0107945:	68 54 ad 10 c0       	push   $0xc010ad54
c010794a:	e8 a1 8a ff ff       	call   c01003f0 <__panic>

    free_page(p);
c010794f:	83 ec 08             	sub    $0x8,%esp
c0107952:	6a 01                	push   $0x1
c0107954:	ff 75 e0             	pushl  -0x20(%ebp)
c0107957:	e8 ee ed ff ff       	call   c010674a <free_pages>
c010795c:	83 c4 10             	add    $0x10,%esp
    free_page(pde2page(boot_pgdir[0]));
c010795f:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107964:	8b 00                	mov    (%eax),%eax
c0107966:	83 ec 0c             	sub    $0xc,%esp
c0107969:	50                   	push   %eax
c010796a:	e8 45 eb ff ff       	call   c01064b4 <pde2page>
c010796f:	83 c4 10             	add    $0x10,%esp
c0107972:	83 ec 08             	sub    $0x8,%esp
c0107975:	6a 01                	push   $0x1
c0107977:	50                   	push   %eax
c0107978:	e8 cd ed ff ff       	call   c010674a <free_pages>
c010797d:	83 c4 10             	add    $0x10,%esp
    boot_pgdir[0] = 0;
c0107980:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107985:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c010798b:	83 ec 0c             	sub    $0xc,%esp
c010798e:	68 10 b2 10 c0       	push   $0xc010b210
c0107993:	e8 f2 88 ff ff       	call   c010028a <cprintf>
c0107998:	83 c4 10             	add    $0x10,%esp
}
c010799b:	90                   	nop
c010799c:	c9                   	leave  
c010799d:	c3                   	ret    

c010799e <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c010799e:	55                   	push   %ebp
c010799f:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c01079a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01079a4:	83 e0 04             	and    $0x4,%eax
c01079a7:	85 c0                	test   %eax,%eax
c01079a9:	74 07                	je     c01079b2 <perm2str+0x14>
c01079ab:	b8 75 00 00 00       	mov    $0x75,%eax
c01079b0:	eb 05                	jmp    c01079b7 <perm2str+0x19>
c01079b2:	b8 2d 00 00 00       	mov    $0x2d,%eax
c01079b7:	a2 08 80 12 c0       	mov    %al,0xc0128008
    str[1] = 'r';
c01079bc:	c6 05 09 80 12 c0 72 	movb   $0x72,0xc0128009
    str[2] = (perm & PTE_W) ? 'w' : '-';
c01079c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01079c6:	83 e0 02             	and    $0x2,%eax
c01079c9:	85 c0                	test   %eax,%eax
c01079cb:	74 07                	je     c01079d4 <perm2str+0x36>
c01079cd:	b8 77 00 00 00       	mov    $0x77,%eax
c01079d2:	eb 05                	jmp    c01079d9 <perm2str+0x3b>
c01079d4:	b8 2d 00 00 00       	mov    $0x2d,%eax
c01079d9:	a2 0a 80 12 c0       	mov    %al,0xc012800a
    str[3] = '\0';
c01079de:	c6 05 0b 80 12 c0 00 	movb   $0x0,0xc012800b
    return str;
c01079e5:	b8 08 80 12 c0       	mov    $0xc0128008,%eax
}
c01079ea:	5d                   	pop    %ebp
c01079eb:	c3                   	ret    

c01079ec <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c01079ec:	55                   	push   %ebp
c01079ed:	89 e5                	mov    %esp,%ebp
c01079ef:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c01079f2:	8b 45 10             	mov    0x10(%ebp),%eax
c01079f5:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01079f8:	72 0e                	jb     c0107a08 <get_pgtable_items+0x1c>
        return 0;
c01079fa:	b8 00 00 00 00       	mov    $0x0,%eax
c01079ff:	e9 9a 00 00 00       	jmp    c0107a9e <get_pgtable_items+0xb2>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0107a04:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0107a08:	8b 45 10             	mov    0x10(%ebp),%eax
c0107a0b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107a0e:	73 18                	jae    c0107a28 <get_pgtable_items+0x3c>
c0107a10:	8b 45 10             	mov    0x10(%ebp),%eax
c0107a13:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107a1a:	8b 45 14             	mov    0x14(%ebp),%eax
c0107a1d:	01 d0                	add    %edx,%eax
c0107a1f:	8b 00                	mov    (%eax),%eax
c0107a21:	83 e0 01             	and    $0x1,%eax
c0107a24:	85 c0                	test   %eax,%eax
c0107a26:	74 dc                	je     c0107a04 <get_pgtable_items+0x18>
        start ++;
    }
    if (start < right) {
c0107a28:	8b 45 10             	mov    0x10(%ebp),%eax
c0107a2b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107a2e:	73 69                	jae    c0107a99 <get_pgtable_items+0xad>
        if (left_store != NULL) {
c0107a30:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0107a34:	74 08                	je     c0107a3e <get_pgtable_items+0x52>
            *left_store = start;
c0107a36:	8b 45 18             	mov    0x18(%ebp),%eax
c0107a39:	8b 55 10             	mov    0x10(%ebp),%edx
c0107a3c:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0107a3e:	8b 45 10             	mov    0x10(%ebp),%eax
c0107a41:	8d 50 01             	lea    0x1(%eax),%edx
c0107a44:	89 55 10             	mov    %edx,0x10(%ebp)
c0107a47:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107a4e:	8b 45 14             	mov    0x14(%ebp),%eax
c0107a51:	01 d0                	add    %edx,%eax
c0107a53:	8b 00                	mov    (%eax),%eax
c0107a55:	83 e0 07             	and    $0x7,%eax
c0107a58:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0107a5b:	eb 04                	jmp    c0107a61 <get_pgtable_items+0x75>
            start ++;
c0107a5d:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0107a61:	8b 45 10             	mov    0x10(%ebp),%eax
c0107a64:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107a67:	73 1d                	jae    c0107a86 <get_pgtable_items+0x9a>
c0107a69:	8b 45 10             	mov    0x10(%ebp),%eax
c0107a6c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107a73:	8b 45 14             	mov    0x14(%ebp),%eax
c0107a76:	01 d0                	add    %edx,%eax
c0107a78:	8b 00                	mov    (%eax),%eax
c0107a7a:	83 e0 07             	and    $0x7,%eax
c0107a7d:	89 c2                	mov    %eax,%edx
c0107a7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107a82:	39 c2                	cmp    %eax,%edx
c0107a84:	74 d7                	je     c0107a5d <get_pgtable_items+0x71>
            start ++;
        }
        if (right_store != NULL) {
c0107a86:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0107a8a:	74 08                	je     c0107a94 <get_pgtable_items+0xa8>
            *right_store = start;
c0107a8c:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0107a8f:	8b 55 10             	mov    0x10(%ebp),%edx
c0107a92:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0107a94:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107a97:	eb 05                	jmp    c0107a9e <get_pgtable_items+0xb2>
    }
    return 0;
c0107a99:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107a9e:	c9                   	leave  
c0107a9f:	c3                   	ret    

c0107aa0 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0107aa0:	55                   	push   %ebp
c0107aa1:	89 e5                	mov    %esp,%ebp
c0107aa3:	57                   	push   %edi
c0107aa4:	56                   	push   %esi
c0107aa5:	53                   	push   %ebx
c0107aa6:	83 ec 2c             	sub    $0x2c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0107aa9:	83 ec 0c             	sub    $0xc,%esp
c0107aac:	68 30 b2 10 c0       	push   $0xc010b230
c0107ab1:	e8 d4 87 ff ff       	call   c010028a <cprintf>
c0107ab6:	83 c4 10             	add    $0x10,%esp
    size_t left, right = 0, perm;
c0107ab9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0107ac0:	e9 e5 00 00 00       	jmp    c0107baa <print_pgdir+0x10a>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0107ac5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107ac8:	83 ec 0c             	sub    $0xc,%esp
c0107acb:	50                   	push   %eax
c0107acc:	e8 cd fe ff ff       	call   c010799e <perm2str>
c0107ad1:	83 c4 10             	add    $0x10,%esp
c0107ad4:	89 c7                	mov    %eax,%edi
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0107ad6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107ad9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107adc:	29 c2                	sub    %eax,%edx
c0107ade:	89 d0                	mov    %edx,%eax
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0107ae0:	c1 e0 16             	shl    $0x16,%eax
c0107ae3:	89 c3                	mov    %eax,%ebx
c0107ae5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107ae8:	c1 e0 16             	shl    $0x16,%eax
c0107aeb:	89 c1                	mov    %eax,%ecx
c0107aed:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107af0:	c1 e0 16             	shl    $0x16,%eax
c0107af3:	89 c2                	mov    %eax,%edx
c0107af5:	8b 75 dc             	mov    -0x24(%ebp),%esi
c0107af8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107afb:	29 c6                	sub    %eax,%esi
c0107afd:	89 f0                	mov    %esi,%eax
c0107aff:	83 ec 08             	sub    $0x8,%esp
c0107b02:	57                   	push   %edi
c0107b03:	53                   	push   %ebx
c0107b04:	51                   	push   %ecx
c0107b05:	52                   	push   %edx
c0107b06:	50                   	push   %eax
c0107b07:	68 61 b2 10 c0       	push   $0xc010b261
c0107b0c:	e8 79 87 ff ff       	call   c010028a <cprintf>
c0107b11:	83 c4 20             	add    $0x20,%esp
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0107b14:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107b17:	c1 e0 0a             	shl    $0xa,%eax
c0107b1a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0107b1d:	eb 4f                	jmp    c0107b6e <print_pgdir+0xce>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0107b1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107b22:	83 ec 0c             	sub    $0xc,%esp
c0107b25:	50                   	push   %eax
c0107b26:	e8 73 fe ff ff       	call   c010799e <perm2str>
c0107b2b:	83 c4 10             	add    $0x10,%esp
c0107b2e:	89 c7                	mov    %eax,%edi
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0107b30:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107b33:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107b36:	29 c2                	sub    %eax,%edx
c0107b38:	89 d0                	mov    %edx,%eax
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0107b3a:	c1 e0 0c             	shl    $0xc,%eax
c0107b3d:	89 c3                	mov    %eax,%ebx
c0107b3f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107b42:	c1 e0 0c             	shl    $0xc,%eax
c0107b45:	89 c1                	mov    %eax,%ecx
c0107b47:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107b4a:	c1 e0 0c             	shl    $0xc,%eax
c0107b4d:	89 c2                	mov    %eax,%edx
c0107b4f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
c0107b52:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107b55:	29 c6                	sub    %eax,%esi
c0107b57:	89 f0                	mov    %esi,%eax
c0107b59:	83 ec 08             	sub    $0x8,%esp
c0107b5c:	57                   	push   %edi
c0107b5d:	53                   	push   %ebx
c0107b5e:	51                   	push   %ecx
c0107b5f:	52                   	push   %edx
c0107b60:	50                   	push   %eax
c0107b61:	68 80 b2 10 c0       	push   $0xc010b280
c0107b66:	e8 1f 87 ff ff       	call   c010028a <cprintf>
c0107b6b:	83 c4 20             	add    $0x20,%esp
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0107b6e:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0107b73:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107b76:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107b79:	89 d3                	mov    %edx,%ebx
c0107b7b:	c1 e3 0a             	shl    $0xa,%ebx
c0107b7e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107b81:	89 d1                	mov    %edx,%ecx
c0107b83:	c1 e1 0a             	shl    $0xa,%ecx
c0107b86:	83 ec 08             	sub    $0x8,%esp
c0107b89:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0107b8c:	52                   	push   %edx
c0107b8d:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0107b90:	52                   	push   %edx
c0107b91:	56                   	push   %esi
c0107b92:	50                   	push   %eax
c0107b93:	53                   	push   %ebx
c0107b94:	51                   	push   %ecx
c0107b95:	e8 52 fe ff ff       	call   c01079ec <get_pgtable_items>
c0107b9a:	83 c4 20             	add    $0x20,%esp
c0107b9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107ba0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107ba4:	0f 85 75 ff ff ff    	jne    c0107b1f <print_pgdir+0x7f>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0107baa:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0107baf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107bb2:	83 ec 08             	sub    $0x8,%esp
c0107bb5:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0107bb8:	52                   	push   %edx
c0107bb9:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0107bbc:	52                   	push   %edx
c0107bbd:	51                   	push   %ecx
c0107bbe:	50                   	push   %eax
c0107bbf:	68 00 04 00 00       	push   $0x400
c0107bc4:	6a 00                	push   $0x0
c0107bc6:	e8 21 fe ff ff       	call   c01079ec <get_pgtable_items>
c0107bcb:	83 c4 20             	add    $0x20,%esp
c0107bce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107bd1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107bd5:	0f 85 ea fe ff ff    	jne    c0107ac5 <print_pgdir+0x25>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0107bdb:	83 ec 0c             	sub    $0xc,%esp
c0107bde:	68 a4 b2 10 c0       	push   $0xc010b2a4
c0107be3:	e8 a2 86 ff ff       	call   c010028a <cprintf>
c0107be8:	83 c4 10             	add    $0x10,%esp
}
c0107beb:	90                   	nop
c0107bec:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0107bef:	5b                   	pop    %ebx
c0107bf0:	5e                   	pop    %esi
c0107bf1:	5f                   	pop    %edi
c0107bf2:	5d                   	pop    %ebp
c0107bf3:	c3                   	ret    

c0107bf4 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0107bf4:	55                   	push   %ebp
c0107bf5:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0107bf7:	8b 45 08             	mov    0x8(%ebp),%eax
c0107bfa:	8b 15 58 a1 12 c0    	mov    0xc012a158,%edx
c0107c00:	29 d0                	sub    %edx,%eax
c0107c02:	c1 f8 02             	sar    $0x2,%eax
c0107c05:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c0107c0b:	5d                   	pop    %ebp
c0107c0c:	c3                   	ret    

c0107c0d <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0107c0d:	55                   	push   %ebp
c0107c0e:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c0107c10:	ff 75 08             	pushl  0x8(%ebp)
c0107c13:	e8 dc ff ff ff       	call   c0107bf4 <page2ppn>
c0107c18:	83 c4 04             	add    $0x4,%esp
c0107c1b:	c1 e0 0c             	shl    $0xc,%eax
}
c0107c1e:	c9                   	leave  
c0107c1f:	c3                   	ret    

c0107c20 <page2kva>:
    }
    return &pages[PPN(pa)];
}

static inline void *
page2kva(struct Page *page) {
c0107c20:	55                   	push   %ebp
c0107c21:	89 e5                	mov    %esp,%ebp
c0107c23:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c0107c26:	ff 75 08             	pushl  0x8(%ebp)
c0107c29:	e8 df ff ff ff       	call   c0107c0d <page2pa>
c0107c2e:	83 c4 04             	add    $0x4,%esp
c0107c31:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c37:	c1 e8 0c             	shr    $0xc,%eax
c0107c3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107c3d:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0107c42:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0107c45:	72 14                	jb     c0107c5b <page2kva+0x3b>
c0107c47:	ff 75 f4             	pushl  -0xc(%ebp)
c0107c4a:	68 d8 b2 10 c0       	push   $0xc010b2d8
c0107c4f:	6a 66                	push   $0x66
c0107c51:	68 fb b2 10 c0       	push   $0xc010b2fb
c0107c56:	e8 95 87 ff ff       	call   c01003f0 <__panic>
c0107c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c5e:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0107c63:	c9                   	leave  
c0107c64:	c3                   	ret    

c0107c65 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c0107c65:	55                   	push   %ebp
c0107c66:	89 e5                	mov    %esp,%ebp
c0107c68:	83 ec 08             	sub    $0x8,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c0107c6b:	83 ec 0c             	sub    $0xc,%esp
c0107c6e:	6a 01                	push   $0x1
c0107c70:	e8 ba 93 ff ff       	call   c010102f <ide_device_valid>
c0107c75:	83 c4 10             	add    $0x10,%esp
c0107c78:	85 c0                	test   %eax,%eax
c0107c7a:	75 14                	jne    c0107c90 <swapfs_init+0x2b>
        panic("swap fs isn't available.\n");
c0107c7c:	83 ec 04             	sub    $0x4,%esp
c0107c7f:	68 09 b3 10 c0       	push   $0xc010b309
c0107c84:	6a 0d                	push   $0xd
c0107c86:	68 23 b3 10 c0       	push   $0xc010b323
c0107c8b:	e8 60 87 ff ff       	call   c01003f0 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c0107c90:	83 ec 0c             	sub    $0xc,%esp
c0107c93:	6a 01                	push   $0x1
c0107c95:	e8 d5 93 ff ff       	call   c010106f <ide_device_size>
c0107c9a:	83 c4 10             	add    $0x10,%esp
c0107c9d:	c1 e8 03             	shr    $0x3,%eax
c0107ca0:	a3 1c a1 12 c0       	mov    %eax,0xc012a11c
}
c0107ca5:	90                   	nop
c0107ca6:	c9                   	leave  
c0107ca7:	c3                   	ret    

c0107ca8 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c0107ca8:	55                   	push   %ebp
c0107ca9:	89 e5                	mov    %esp,%ebp
c0107cab:	83 ec 18             	sub    $0x18,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0107cae:	83 ec 0c             	sub    $0xc,%esp
c0107cb1:	ff 75 0c             	pushl  0xc(%ebp)
c0107cb4:	e8 67 ff ff ff       	call   c0107c20 <page2kva>
c0107cb9:	83 c4 10             	add    $0x10,%esp
c0107cbc:	89 c2                	mov    %eax,%edx
c0107cbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0107cc1:	c1 e8 08             	shr    $0x8,%eax
c0107cc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107cc7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107ccb:	74 0a                	je     c0107cd7 <swapfs_read+0x2f>
c0107ccd:	a1 1c a1 12 c0       	mov    0xc012a11c,%eax
c0107cd2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0107cd5:	72 14                	jb     c0107ceb <swapfs_read+0x43>
c0107cd7:	ff 75 08             	pushl  0x8(%ebp)
c0107cda:	68 34 b3 10 c0       	push   $0xc010b334
c0107cdf:	6a 14                	push   $0x14
c0107ce1:	68 23 b3 10 c0       	push   $0xc010b323
c0107ce6:	e8 05 87 ff ff       	call   c01003f0 <__panic>
c0107ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107cee:	c1 e0 03             	shl    $0x3,%eax
c0107cf1:	6a 08                	push   $0x8
c0107cf3:	52                   	push   %edx
c0107cf4:	50                   	push   %eax
c0107cf5:	6a 01                	push   $0x1
c0107cf7:	e8 b3 93 ff ff       	call   c01010af <ide_read_secs>
c0107cfc:	83 c4 10             	add    $0x10,%esp
}
c0107cff:	c9                   	leave  
c0107d00:	c3                   	ret    

c0107d01 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c0107d01:	55                   	push   %ebp
c0107d02:	89 e5                	mov    %esp,%ebp
c0107d04:	83 ec 18             	sub    $0x18,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0107d07:	83 ec 0c             	sub    $0xc,%esp
c0107d0a:	ff 75 0c             	pushl  0xc(%ebp)
c0107d0d:	e8 0e ff ff ff       	call   c0107c20 <page2kva>
c0107d12:	83 c4 10             	add    $0x10,%esp
c0107d15:	89 c2                	mov    %eax,%edx
c0107d17:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d1a:	c1 e8 08             	shr    $0x8,%eax
c0107d1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107d20:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107d24:	74 0a                	je     c0107d30 <swapfs_write+0x2f>
c0107d26:	a1 1c a1 12 c0       	mov    0xc012a11c,%eax
c0107d2b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0107d2e:	72 14                	jb     c0107d44 <swapfs_write+0x43>
c0107d30:	ff 75 08             	pushl  0x8(%ebp)
c0107d33:	68 34 b3 10 c0       	push   $0xc010b334
c0107d38:	6a 19                	push   $0x19
c0107d3a:	68 23 b3 10 c0       	push   $0xc010b323
c0107d3f:	e8 ac 86 ff ff       	call   c01003f0 <__panic>
c0107d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d47:	c1 e0 03             	shl    $0x3,%eax
c0107d4a:	6a 08                	push   $0x8
c0107d4c:	52                   	push   %edx
c0107d4d:	50                   	push   %eax
c0107d4e:	6a 01                	push   $0x1
c0107d50:	e8 84 95 ff ff       	call   c01012d9 <ide_write_secs>
c0107d55:	83 c4 10             	add    $0x10,%esp
}
c0107d58:	c9                   	leave  
c0107d59:	c3                   	ret    

c0107d5a <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c0107d5a:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c0107d5e:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)          # save esp::context of from
c0107d60:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)          # save ebx::context of from
c0107d63:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)         # save ecx::context of from
c0107d66:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)         # save edx::context of from
c0107d69:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)         # save esi::context of from
c0107d6c:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)         # save edi::context of from
c0107d6f:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)         # save ebp::context of from
c0107d72:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c0107d75:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp         # restore ebp::context of to
c0107d79:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi         # restore edi::context of to
c0107d7c:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi         # restore esi::context of to
c0107d7f:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx         # restore edx::context of to
c0107d82:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx         # restore ecx::context of to
c0107d85:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx          # restore ebx::context of to
c0107d88:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp          # restore esp::context of to
c0107d8b:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c0107d8e:	ff 30                	pushl  (%eax)

    ret
c0107d90:	c3                   	ret    

c0107d91 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c0107d91:	52                   	push   %edx
    call *%ebx              # call fn
c0107d92:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c0107d94:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c0107d95:	e8 c0 07 00 00       	call   c010855a <do_exit>

c0107d9a <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0107d9a:	55                   	push   %ebp
c0107d9b:	89 e5                	mov    %esp,%ebp
c0107d9d:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0107da0:	9c                   	pushf  
c0107da1:	58                   	pop    %eax
c0107da2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0107da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0107da8:	25 00 02 00 00       	and    $0x200,%eax
c0107dad:	85 c0                	test   %eax,%eax
c0107daf:	74 0c                	je     c0107dbd <__intr_save+0x23>
        intr_disable();
c0107db1:	e8 5c a2 ff ff       	call   c0102012 <intr_disable>
        return 1;
c0107db6:	b8 01 00 00 00       	mov    $0x1,%eax
c0107dbb:	eb 05                	jmp    c0107dc2 <__intr_save+0x28>
    }
    return 0;
c0107dbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107dc2:	c9                   	leave  
c0107dc3:	c3                   	ret    

c0107dc4 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0107dc4:	55                   	push   %ebp
c0107dc5:	89 e5                	mov    %esp,%ebp
c0107dc7:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0107dca:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107dce:	74 05                	je     c0107dd5 <__intr_restore+0x11>
        intr_enable();
c0107dd0:	e8 36 a2 ff ff       	call   c010200b <intr_enable>
    }
}
c0107dd5:	90                   	nop
c0107dd6:	c9                   	leave  
c0107dd7:	c3                   	ret    

c0107dd8 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0107dd8:	55                   	push   %ebp
c0107dd9:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0107ddb:	8b 45 08             	mov    0x8(%ebp),%eax
c0107dde:	8b 15 58 a1 12 c0    	mov    0xc012a158,%edx
c0107de4:	29 d0                	sub    %edx,%eax
c0107de6:	c1 f8 02             	sar    $0x2,%eax
c0107de9:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c0107def:	5d                   	pop    %ebp
c0107df0:	c3                   	ret    

c0107df1 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0107df1:	55                   	push   %ebp
c0107df2:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c0107df4:	ff 75 08             	pushl  0x8(%ebp)
c0107df7:	e8 dc ff ff ff       	call   c0107dd8 <page2ppn>
c0107dfc:	83 c4 04             	add    $0x4,%esp
c0107dff:	c1 e0 0c             	shl    $0xc,%eax
}
c0107e02:	c9                   	leave  
c0107e03:	c3                   	ret    

c0107e04 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0107e04:	55                   	push   %ebp
c0107e05:	89 e5                	mov    %esp,%ebp
c0107e07:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0107e0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e0d:	c1 e8 0c             	shr    $0xc,%eax
c0107e10:	89 c2                	mov    %eax,%edx
c0107e12:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0107e17:	39 c2                	cmp    %eax,%edx
c0107e19:	72 14                	jb     c0107e2f <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0107e1b:	83 ec 04             	sub    $0x4,%esp
c0107e1e:	68 54 b3 10 c0       	push   $0xc010b354
c0107e23:	6a 5f                	push   $0x5f
c0107e25:	68 73 b3 10 c0       	push   $0xc010b373
c0107e2a:	e8 c1 85 ff ff       	call   c01003f0 <__panic>
    }
    return &pages[PPN(pa)];
c0107e2f:	8b 0d 58 a1 12 c0    	mov    0xc012a158,%ecx
c0107e35:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e38:	c1 e8 0c             	shr    $0xc,%eax
c0107e3b:	89 c2                	mov    %eax,%edx
c0107e3d:	89 d0                	mov    %edx,%eax
c0107e3f:	c1 e0 03             	shl    $0x3,%eax
c0107e42:	01 d0                	add    %edx,%eax
c0107e44:	c1 e0 02             	shl    $0x2,%eax
c0107e47:	01 c8                	add    %ecx,%eax
}
c0107e49:	c9                   	leave  
c0107e4a:	c3                   	ret    

c0107e4b <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0107e4b:	55                   	push   %ebp
c0107e4c:	89 e5                	mov    %esp,%ebp
c0107e4e:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c0107e51:	ff 75 08             	pushl  0x8(%ebp)
c0107e54:	e8 98 ff ff ff       	call   c0107df1 <page2pa>
c0107e59:	83 c4 04             	add    $0x4,%esp
c0107e5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107e5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e62:	c1 e8 0c             	shr    $0xc,%eax
c0107e65:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107e68:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0107e6d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0107e70:	72 14                	jb     c0107e86 <page2kva+0x3b>
c0107e72:	ff 75 f4             	pushl  -0xc(%ebp)
c0107e75:	68 84 b3 10 c0       	push   $0xc010b384
c0107e7a:	6a 66                	push   $0x66
c0107e7c:	68 73 b3 10 c0       	push   $0xc010b373
c0107e81:	e8 6a 85 ff ff       	call   c01003f0 <__panic>
c0107e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e89:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0107e8e:	c9                   	leave  
c0107e8f:	c3                   	ret    

c0107e90 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c0107e90:	55                   	push   %ebp
c0107e91:	89 e5                	mov    %esp,%ebp
c0107e93:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PADDR(kva));
c0107e96:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e99:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107e9c:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0107ea3:	77 14                	ja     c0107eb9 <kva2page+0x29>
c0107ea5:	ff 75 f4             	pushl  -0xc(%ebp)
c0107ea8:	68 a8 b3 10 c0       	push   $0xc010b3a8
c0107ead:	6a 6b                	push   $0x6b
c0107eaf:	68 73 b3 10 c0       	push   $0xc010b373
c0107eb4:	e8 37 85 ff ff       	call   c01003f0 <__panic>
c0107eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ebc:	05 00 00 00 40       	add    $0x40000000,%eax
c0107ec1:	83 ec 0c             	sub    $0xc,%esp
c0107ec4:	50                   	push   %eax
c0107ec5:	e8 3a ff ff ff       	call   c0107e04 <pa2page>
c0107eca:	83 c4 10             	add    $0x10,%esp
}
c0107ecd:	c9                   	leave  
c0107ece:	c3                   	ret    

c0107ecf <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c0107ecf:	55                   	push   %ebp
c0107ed0:	89 e5                	mov    %esp,%ebp
c0107ed2:	83 ec 18             	sub    $0x18,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c0107ed5:	83 ec 0c             	sub    $0xc,%esp
c0107ed8:	6a 68                	push   $0x68
c0107eda:	e8 c9 c8 ff ff       	call   c01047a8 <kmalloc>
c0107edf:	83 c4 10             	add    $0x10,%esp
c0107ee2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c0107ee5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107ee9:	0f 84 91 00 00 00    	je     c0107f80 <alloc_proc+0xb1>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
     proc->state = PROC_UNINIT;
c0107eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ef2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     proc->pid = -1;
c0107ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107efb:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
     proc->runs = 0;
c0107f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f05:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
     proc->kstack = 0;
c0107f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f0f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
     proc->need_resched = 0;
c0107f16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f19:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
     proc->parent = NULL;
c0107f20:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f23:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
     proc->mm = NULL;
c0107f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f2d:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
     memset(&(proc->context), 0, sizeof(struct context));
c0107f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f37:	83 c0 1c             	add    $0x1c,%eax
c0107f3a:	83 ec 04             	sub    $0x4,%esp
c0107f3d:	6a 20                	push   $0x20
c0107f3f:	6a 00                	push   $0x0
c0107f41:	50                   	push   %eax
c0107f42:	e8 bf 0c 00 00       	call   c0108c06 <memset>
c0107f47:	83 c4 10             	add    $0x10,%esp
     proc->tf = NULL;
c0107f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f4d:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
     proc->cr3 = boot_cr3;
c0107f54:	8b 15 54 a1 12 c0    	mov    0xc012a154,%edx
c0107f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f5d:	89 50 40             	mov    %edx,0x40(%eax)
     proc->flags = 0;
c0107f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f63:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
     memset(proc->name, 0, PROC_NAME_LEN);
c0107f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f6d:	83 c0 48             	add    $0x48,%eax
c0107f70:	83 ec 04             	sub    $0x4,%esp
c0107f73:	6a 0f                	push   $0xf
c0107f75:	6a 00                	push   $0x0
c0107f77:	50                   	push   %eax
c0107f78:	e8 89 0c 00 00       	call   c0108c06 <memset>
c0107f7d:	83 c4 10             	add    $0x10,%esp
    }
    return proc;
c0107f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107f83:	c9                   	leave  
c0107f84:	c3                   	ret    

c0107f85 <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c0107f85:	55                   	push   %ebp
c0107f86:	89 e5                	mov    %esp,%ebp
c0107f88:	83 ec 08             	sub    $0x8,%esp
    memset(proc->name, 0, sizeof(proc->name));
c0107f8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f8e:	83 c0 48             	add    $0x48,%eax
c0107f91:	83 ec 04             	sub    $0x4,%esp
c0107f94:	6a 10                	push   $0x10
c0107f96:	6a 00                	push   $0x0
c0107f98:	50                   	push   %eax
c0107f99:	e8 68 0c 00 00       	call   c0108c06 <memset>
c0107f9e:	83 c4 10             	add    $0x10,%esp
    return memcpy(proc->name, name, PROC_NAME_LEN);
c0107fa1:	8b 45 08             	mov    0x8(%ebp),%eax
c0107fa4:	83 c0 48             	add    $0x48,%eax
c0107fa7:	83 ec 04             	sub    $0x4,%esp
c0107faa:	6a 0f                	push   $0xf
c0107fac:	ff 75 0c             	pushl  0xc(%ebp)
c0107faf:	50                   	push   %eax
c0107fb0:	e8 34 0d 00 00       	call   c0108ce9 <memcpy>
c0107fb5:	83 c4 10             	add    $0x10,%esp
}
c0107fb8:	c9                   	leave  
c0107fb9:	c3                   	ret    

c0107fba <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c0107fba:	55                   	push   %ebp
c0107fbb:	89 e5                	mov    %esp,%ebp
c0107fbd:	83 ec 08             	sub    $0x8,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c0107fc0:	83 ec 04             	sub    $0x4,%esp
c0107fc3:	6a 10                	push   $0x10
c0107fc5:	6a 00                	push   $0x0
c0107fc7:	68 44 a0 12 c0       	push   $0xc012a044
c0107fcc:	e8 35 0c 00 00       	call   c0108c06 <memset>
c0107fd1:	83 c4 10             	add    $0x10,%esp
    return memcpy(name, proc->name, PROC_NAME_LEN);
c0107fd4:	8b 45 08             	mov    0x8(%ebp),%eax
c0107fd7:	83 c0 48             	add    $0x48,%eax
c0107fda:	83 ec 04             	sub    $0x4,%esp
c0107fdd:	6a 0f                	push   $0xf
c0107fdf:	50                   	push   %eax
c0107fe0:	68 44 a0 12 c0       	push   $0xc012a044
c0107fe5:	e8 ff 0c 00 00       	call   c0108ce9 <memcpy>
c0107fea:	83 c4 10             	add    $0x10,%esp
}
c0107fed:	c9                   	leave  
c0107fee:	c3                   	ret    

c0107fef <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c0107fef:	55                   	push   %ebp
c0107ff0:	89 e5                	mov    %esp,%ebp
c0107ff2:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c0107ff5:	c7 45 f8 5c a1 12 c0 	movl   $0xc012a15c,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c0107ffc:	a1 78 4a 12 c0       	mov    0xc0124a78,%eax
c0108001:	83 c0 01             	add    $0x1,%eax
c0108004:	a3 78 4a 12 c0       	mov    %eax,0xc0124a78
c0108009:	a1 78 4a 12 c0       	mov    0xc0124a78,%eax
c010800e:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0108013:	7e 0c                	jle    c0108021 <get_pid+0x32>
        last_pid = 1;
c0108015:	c7 05 78 4a 12 c0 01 	movl   $0x1,0xc0124a78
c010801c:	00 00 00 
        goto inside;
c010801f:	eb 13                	jmp    c0108034 <get_pid+0x45>
    }
    if (last_pid >= next_safe) {
c0108021:	8b 15 78 4a 12 c0    	mov    0xc0124a78,%edx
c0108027:	a1 7c 4a 12 c0       	mov    0xc0124a7c,%eax
c010802c:	39 c2                	cmp    %eax,%edx
c010802e:	0f 8c ac 00 00 00    	jl     c01080e0 <get_pid+0xf1>
    inside:
        next_safe = MAX_PID;
c0108034:	c7 05 7c 4a 12 c0 00 	movl   $0x2000,0xc0124a7c
c010803b:	20 00 00 
    repeat:
        le = list;
c010803e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108041:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c0108044:	eb 7f                	jmp    c01080c5 <get_pid+0xd6>
            proc = le2proc(le, list_link);
c0108046:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108049:	83 e8 58             	sub    $0x58,%eax
c010804c:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c010804f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108052:	8b 50 04             	mov    0x4(%eax),%edx
c0108055:	a1 78 4a 12 c0       	mov    0xc0124a78,%eax
c010805a:	39 c2                	cmp    %eax,%edx
c010805c:	75 3e                	jne    c010809c <get_pid+0xad>
                if (++ last_pid >= next_safe) {
c010805e:	a1 78 4a 12 c0       	mov    0xc0124a78,%eax
c0108063:	83 c0 01             	add    $0x1,%eax
c0108066:	a3 78 4a 12 c0       	mov    %eax,0xc0124a78
c010806b:	8b 15 78 4a 12 c0    	mov    0xc0124a78,%edx
c0108071:	a1 7c 4a 12 c0       	mov    0xc0124a7c,%eax
c0108076:	39 c2                	cmp    %eax,%edx
c0108078:	7c 4b                	jl     c01080c5 <get_pid+0xd6>
                    if (last_pid >= MAX_PID) {
c010807a:	a1 78 4a 12 c0       	mov    0xc0124a78,%eax
c010807f:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0108084:	7e 0a                	jle    c0108090 <get_pid+0xa1>
                        last_pid = 1;
c0108086:	c7 05 78 4a 12 c0 01 	movl   $0x1,0xc0124a78
c010808d:	00 00 00 
                    }
                    next_safe = MAX_PID;
c0108090:	c7 05 7c 4a 12 c0 00 	movl   $0x2000,0xc0124a7c
c0108097:	20 00 00 
                    goto repeat;
c010809a:	eb a2                	jmp    c010803e <get_pid+0x4f>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
c010809c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010809f:	8b 50 04             	mov    0x4(%eax),%edx
c01080a2:	a1 78 4a 12 c0       	mov    0xc0124a78,%eax
c01080a7:	39 c2                	cmp    %eax,%edx
c01080a9:	7e 1a                	jle    c01080c5 <get_pid+0xd6>
c01080ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080ae:	8b 50 04             	mov    0x4(%eax),%edx
c01080b1:	a1 7c 4a 12 c0       	mov    0xc0124a7c,%eax
c01080b6:	39 c2                	cmp    %eax,%edx
c01080b8:	7d 0b                	jge    c01080c5 <get_pid+0xd6>
                next_safe = proc->pid;
c01080ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080bd:	8b 40 04             	mov    0x4(%eax),%eax
c01080c0:	a3 7c 4a 12 c0       	mov    %eax,0xc0124a7c
c01080c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01080c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01080cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01080ce:	8b 40 04             	mov    0x4(%eax),%eax
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
c01080d1:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01080d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01080d7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01080da:	0f 85 66 ff ff ff    	jne    c0108046 <get_pid+0x57>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
c01080e0:	a1 78 4a 12 c0       	mov    0xc0124a78,%eax
}
c01080e5:	c9                   	leave  
c01080e6:	c3                   	ret    

c01080e7 <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c01080e7:	55                   	push   %ebp
c01080e8:	89 e5                	mov    %esp,%ebp
c01080ea:	83 ec 18             	sub    $0x18,%esp
    if (proc != current) {
c01080ed:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c01080f2:	39 45 08             	cmp    %eax,0x8(%ebp)
c01080f5:	74 6b                	je     c0108162 <proc_run+0x7b>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c01080f7:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c01080fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01080ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0108102:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c0108105:	e8 90 fc ff ff       	call   c0107d9a <__intr_save>
c010810a:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c010810d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108110:	a3 28 80 12 c0       	mov    %eax,0xc0128028
            load_esp0(next->kstack + KSTACKSIZE);
c0108115:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108118:	8b 40 0c             	mov    0xc(%eax),%eax
c010811b:	05 00 20 00 00       	add    $0x2000,%eax
c0108120:	83 ec 0c             	sub    $0xc,%esp
c0108123:	50                   	push   %eax
c0108124:	e8 61 e4 ff ff       	call   c010658a <load_esp0>
c0108129:	83 c4 10             	add    $0x10,%esp
            lcr3(next->cr3);
c010812c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010812f:	8b 40 40             	mov    0x40(%eax),%eax
c0108132:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0108135:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108138:	0f 22 d8             	mov    %eax,%cr3
            switch_to(&(prev->context), &(next->context));
c010813b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010813e:	8d 50 1c             	lea    0x1c(%eax),%edx
c0108141:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108144:	83 c0 1c             	add    $0x1c,%eax
c0108147:	83 ec 08             	sub    $0x8,%esp
c010814a:	52                   	push   %edx
c010814b:	50                   	push   %eax
c010814c:	e8 09 fc ff ff       	call   c0107d5a <switch_to>
c0108151:	83 c4 10             	add    $0x10,%esp
        }
        local_intr_restore(intr_flag);
c0108154:	83 ec 0c             	sub    $0xc,%esp
c0108157:	ff 75 ec             	pushl  -0x14(%ebp)
c010815a:	e8 65 fc ff ff       	call   c0107dc4 <__intr_restore>
c010815f:	83 c4 10             	add    $0x10,%esp
    }
}
c0108162:	90                   	nop
c0108163:	c9                   	leave  
c0108164:	c3                   	ret    

c0108165 <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c0108165:	55                   	push   %ebp
c0108166:	89 e5                	mov    %esp,%ebp
c0108168:	83 ec 08             	sub    $0x8,%esp
    forkrets(current->tf);
c010816b:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c0108170:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108173:	83 ec 0c             	sub    $0xc,%esp
c0108176:	50                   	push   %eax
c0108177:	e8 75 af ff ff       	call   c01030f1 <forkrets>
c010817c:	83 c4 10             	add    $0x10,%esp
}
c010817f:	90                   	nop
c0108180:	c9                   	leave  
c0108181:	c3                   	ret    

c0108182 <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c0108182:	55                   	push   %ebp
c0108183:	89 e5                	mov    %esp,%ebp
c0108185:	53                   	push   %ebx
c0108186:	83 ec 24             	sub    $0x24,%esp
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c0108189:	8b 45 08             	mov    0x8(%ebp),%eax
c010818c:	8d 58 60             	lea    0x60(%eax),%ebx
c010818f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108192:	8b 40 04             	mov    0x4(%eax),%eax
c0108195:	83 ec 08             	sub    $0x8,%esp
c0108198:	6a 0a                	push   $0xa
c010819a:	50                   	push   %eax
c010819b:	e8 fd 11 00 00       	call   c010939d <hash32>
c01081a0:	83 c4 10             	add    $0x10,%esp
c01081a3:	c1 e0 03             	shl    $0x3,%eax
c01081a6:	05 40 80 12 c0       	add    $0xc0128040,%eax
c01081ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01081ae:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c01081b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01081b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01081b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01081ba:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01081bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01081c0:	8b 40 04             	mov    0x4(%eax),%eax
c01081c3:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01081c6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01081c9:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01081cc:	89 55 e0             	mov    %edx,-0x20(%ebp)
c01081cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01081d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01081d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01081d8:	89 10                	mov    %edx,(%eax)
c01081da:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01081dd:	8b 10                	mov    (%eax),%edx
c01081df:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01081e2:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01081e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01081e8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01081eb:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01081ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01081f1:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01081f4:	89 10                	mov    %edx,(%eax)
}
c01081f6:	90                   	nop
c01081f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01081fa:	c9                   	leave  
c01081fb:	c3                   	ret    

c01081fc <find_proc>:

// find_proc - find proc from proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c01081fc:	55                   	push   %ebp
c01081fd:	89 e5                	mov    %esp,%ebp
c01081ff:	83 ec 18             	sub    $0x18,%esp
    if (0 < pid && pid < MAX_PID) {
c0108202:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108206:	7e 5d                	jle    c0108265 <find_proc+0x69>
c0108208:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c010820f:	7f 54                	jg     c0108265 <find_proc+0x69>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c0108211:	8b 45 08             	mov    0x8(%ebp),%eax
c0108214:	83 ec 08             	sub    $0x8,%esp
c0108217:	6a 0a                	push   $0xa
c0108219:	50                   	push   %eax
c010821a:	e8 7e 11 00 00       	call   c010939d <hash32>
c010821f:	83 c4 10             	add    $0x10,%esp
c0108222:	c1 e0 03             	shl    $0x3,%eax
c0108225:	05 40 80 12 c0       	add    $0xc0128040,%eax
c010822a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010822d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108230:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c0108233:	eb 19                	jmp    c010824e <find_proc+0x52>
            struct proc_struct *proc = le2proc(le, hash_link);
c0108235:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108238:	83 e8 60             	sub    $0x60,%eax
c010823b:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c010823e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108241:	8b 40 04             	mov    0x4(%eax),%eax
c0108244:	3b 45 08             	cmp    0x8(%ebp),%eax
c0108247:	75 05                	jne    c010824e <find_proc+0x52>
                return proc;
c0108249:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010824c:	eb 1c                	jmp    c010826a <find_proc+0x6e>
c010824e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108251:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0108254:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108257:	8b 40 04             	mov    0x4(%eax),%eax
// find_proc - find proc from proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le)) != list) {
c010825a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010825d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108260:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108263:	75 d0                	jne    c0108235 <find_proc+0x39>
            if (proc->pid == pid) {
                return proc;
            }
        }
    }
    return NULL;
c0108265:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010826a:	c9                   	leave  
c010826b:	c3                   	ret    

c010826c <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c010826c:	55                   	push   %ebp
c010826d:	89 e5                	mov    %esp,%ebp
c010826f:	83 ec 58             	sub    $0x58,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c0108272:	83 ec 04             	sub    $0x4,%esp
c0108275:	6a 4c                	push   $0x4c
c0108277:	6a 00                	push   $0x0
c0108279:	8d 45 ac             	lea    -0x54(%ebp),%eax
c010827c:	50                   	push   %eax
c010827d:	e8 84 09 00 00       	call   c0108c06 <memset>
c0108282:	83 c4 10             	add    $0x10,%esp
    tf.tf_cs = KERNEL_CS;
c0108285:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c010828b:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c0108291:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0108295:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0108299:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c010829d:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c01082a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01082a4:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c01082a7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01082aa:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c01082ad:	b8 91 7d 10 c0       	mov    $0xc0107d91,%eax
c01082b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c01082b5:	8b 45 10             	mov    0x10(%ebp),%eax
c01082b8:	80 cc 01             	or     $0x1,%ah
c01082bb:	89 c2                	mov    %eax,%edx
c01082bd:	83 ec 04             	sub    $0x4,%esp
c01082c0:	8d 45 ac             	lea    -0x54(%ebp),%eax
c01082c3:	50                   	push   %eax
c01082c4:	6a 00                	push   $0x0
c01082c6:	52                   	push   %edx
c01082c7:	e8 3c 01 00 00       	call   c0108408 <do_fork>
c01082cc:	83 c4 10             	add    $0x10,%esp
}
c01082cf:	c9                   	leave  
c01082d0:	c3                   	ret    

c01082d1 <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c01082d1:	55                   	push   %ebp
c01082d2:	89 e5                	mov    %esp,%ebp
c01082d4:	83 ec 18             	sub    $0x18,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c01082d7:	83 ec 0c             	sub    $0xc,%esp
c01082da:	6a 02                	push   $0x2
c01082dc:	e8 fd e3 ff ff       	call   c01066de <alloc_pages>
c01082e1:	83 c4 10             	add    $0x10,%esp
c01082e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c01082e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01082eb:	74 1d                	je     c010830a <setup_kstack+0x39>
        proc->kstack = (uintptr_t)page2kva(page);
c01082ed:	83 ec 0c             	sub    $0xc,%esp
c01082f0:	ff 75 f4             	pushl  -0xc(%ebp)
c01082f3:	e8 53 fb ff ff       	call   c0107e4b <page2kva>
c01082f8:	83 c4 10             	add    $0x10,%esp
c01082fb:	89 c2                	mov    %eax,%edx
c01082fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0108300:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c0108303:	b8 00 00 00 00       	mov    $0x0,%eax
c0108308:	eb 05                	jmp    c010830f <setup_kstack+0x3e>
    }
    return -E_NO_MEM;
c010830a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c010830f:	c9                   	leave  
c0108310:	c3                   	ret    

c0108311 <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c0108311:	55                   	push   %ebp
c0108312:	89 e5                	mov    %esp,%ebp
c0108314:	83 ec 08             	sub    $0x8,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c0108317:	8b 45 08             	mov    0x8(%ebp),%eax
c010831a:	8b 40 0c             	mov    0xc(%eax),%eax
c010831d:	83 ec 0c             	sub    $0xc,%esp
c0108320:	50                   	push   %eax
c0108321:	e8 6a fb ff ff       	call   c0107e90 <kva2page>
c0108326:	83 c4 10             	add    $0x10,%esp
c0108329:	83 ec 08             	sub    $0x8,%esp
c010832c:	6a 02                	push   $0x2
c010832e:	50                   	push   %eax
c010832f:	e8 16 e4 ff ff       	call   c010674a <free_pages>
c0108334:	83 c4 10             	add    $0x10,%esp
}
c0108337:	90                   	nop
c0108338:	c9                   	leave  
c0108339:	c3                   	ret    

c010833a <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c010833a:	55                   	push   %ebp
c010833b:	89 e5                	mov    %esp,%ebp
c010833d:	83 ec 08             	sub    $0x8,%esp
    assert(current->mm == NULL);
c0108340:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c0108345:	8b 40 18             	mov    0x18(%eax),%eax
c0108348:	85 c0                	test   %eax,%eax
c010834a:	74 19                	je     c0108365 <copy_mm+0x2b>
c010834c:	68 cc b3 10 c0       	push   $0xc010b3cc
c0108351:	68 e0 b3 10 c0       	push   $0xc010b3e0
c0108356:	68 fe 00 00 00       	push   $0xfe
c010835b:	68 f5 b3 10 c0       	push   $0xc010b3f5
c0108360:	e8 8b 80 ff ff       	call   c01003f0 <__panic>
    /* do nothing in this project */
    return 0;
c0108365:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010836a:	c9                   	leave  
c010836b:	c3                   	ret    

c010836c <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c010836c:	55                   	push   %ebp
c010836d:	89 e5                	mov    %esp,%ebp
c010836f:	57                   	push   %edi
c0108370:	56                   	push   %esi
c0108371:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c0108372:	8b 45 08             	mov    0x8(%ebp),%eax
c0108375:	8b 40 0c             	mov    0xc(%eax),%eax
c0108378:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c010837d:	89 c2                	mov    %eax,%edx
c010837f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108382:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c0108385:	8b 45 08             	mov    0x8(%ebp),%eax
c0108388:	8b 40 3c             	mov    0x3c(%eax),%eax
c010838b:	8b 55 10             	mov    0x10(%ebp),%edx
c010838e:	89 d3                	mov    %edx,%ebx
c0108390:	ba 4c 00 00 00       	mov    $0x4c,%edx
c0108395:	8b 0b                	mov    (%ebx),%ecx
c0108397:	89 08                	mov    %ecx,(%eax)
c0108399:	8b 4c 13 fc          	mov    -0x4(%ebx,%edx,1),%ecx
c010839d:	89 4c 10 fc          	mov    %ecx,-0x4(%eax,%edx,1)
c01083a1:	8d 78 04             	lea    0x4(%eax),%edi
c01083a4:	83 e7 fc             	and    $0xfffffffc,%edi
c01083a7:	29 f8                	sub    %edi,%eax
c01083a9:	29 c3                	sub    %eax,%ebx
c01083ab:	01 c2                	add    %eax,%edx
c01083ad:	83 e2 fc             	and    $0xfffffffc,%edx
c01083b0:	89 d0                	mov    %edx,%eax
c01083b2:	c1 e8 02             	shr    $0x2,%eax
c01083b5:	89 de                	mov    %ebx,%esi
c01083b7:	89 c1                	mov    %eax,%ecx
c01083b9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    proc->tf->tf_regs.reg_eax = 0;
c01083bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01083be:	8b 40 3c             	mov    0x3c(%eax),%eax
c01083c1:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c01083c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01083cb:	8b 40 3c             	mov    0x3c(%eax),%eax
c01083ce:	8b 55 0c             	mov    0xc(%ebp),%edx
c01083d1:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c01083d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01083d7:	8b 40 3c             	mov    0x3c(%eax),%eax
c01083da:	8b 55 08             	mov    0x8(%ebp),%edx
c01083dd:	8b 52 3c             	mov    0x3c(%edx),%edx
c01083e0:	8b 52 40             	mov    0x40(%edx),%edx
c01083e3:	80 ce 02             	or     $0x2,%dh
c01083e6:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c01083e9:	ba 65 81 10 c0       	mov    $0xc0108165,%edx
c01083ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01083f1:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c01083f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01083f7:	8b 40 3c             	mov    0x3c(%eax),%eax
c01083fa:	89 c2                	mov    %eax,%edx
c01083fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01083ff:	89 50 20             	mov    %edx,0x20(%eax)
}
c0108402:	90                   	nop
c0108403:	5b                   	pop    %ebx
c0108404:	5e                   	pop    %esi
c0108405:	5f                   	pop    %edi
c0108406:	5d                   	pop    %ebp
c0108407:	c3                   	ret    

c0108408 <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c0108408:	55                   	push   %ebp
c0108409:	89 e5                	mov    %esp,%ebp
c010840b:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_NO_FREE_PROC;
c010840e:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c0108415:	a1 40 a0 12 c0       	mov    0xc012a040,%eax
c010841a:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c010841f:	0f 8f 08 01 00 00    	jg     c010852d <do_fork+0x125>
        goto fork_out;
    }
    ret = -E_NO_MEM;
c0108425:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
    if ((proc = alloc_proc()) == NULL) {
c010842c:	e8 9e fa ff ff       	call   c0107ecf <alloc_proc>
c0108431:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108434:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108438:	0f 84 f2 00 00 00    	je     c0108530 <do_fork+0x128>
      goto fork_out;
    }
    if (setup_kstack(proc) != 0) {
c010843e:	83 ec 0c             	sub    $0xc,%esp
c0108441:	ff 75 f0             	pushl  -0x10(%ebp)
c0108444:	e8 88 fe ff ff       	call   c01082d1 <setup_kstack>
c0108449:	83 c4 10             	add    $0x10,%esp
c010844c:	85 c0                	test   %eax,%eax
c010844e:	0f 85 e2 00 00 00    	jne    c0108536 <do_fork+0x12e>
      goto bad_fork_cleanup_kstack;
    }
    if (copy_mm(clone_flags, proc) != 0) {
c0108454:	83 ec 08             	sub    $0x8,%esp
c0108457:	ff 75 f0             	pushl  -0x10(%ebp)
c010845a:	ff 75 08             	pushl  0x8(%ebp)
c010845d:	e8 d8 fe ff ff       	call   c010833a <copy_mm>
c0108462:	83 c4 10             	add    $0x10,%esp
c0108465:	85 c0                	test   %eax,%eax
c0108467:	0f 85 da 00 00 00    	jne    c0108547 <do_fork+0x13f>
      goto bad_fork_cleanup_proc;
    }
    copy_thread(proc, stack, tf);
c010846d:	83 ec 04             	sub    $0x4,%esp
c0108470:	ff 75 10             	pushl  0x10(%ebp)
c0108473:	ff 75 0c             	pushl  0xc(%ebp)
c0108476:	ff 75 f0             	pushl  -0x10(%ebp)
c0108479:	e8 ee fe ff ff       	call   c010836c <copy_thread>
c010847e:	83 c4 10             	add    $0x10,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0108481:	e8 14 f9 ff ff       	call   c0107d9a <__intr_save>
c0108486:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        proc->pid = get_pid();
c0108489:	e8 61 fb ff ff       	call   c0107fef <get_pid>
c010848e:	89 c2                	mov    %eax,%edx
c0108490:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108493:	89 50 04             	mov    %edx,0x4(%eax)
        hash_proc(proc);
c0108496:	83 ec 0c             	sub    $0xc,%esp
c0108499:	ff 75 f0             	pushl  -0x10(%ebp)
c010849c:	e8 e1 fc ff ff       	call   c0108182 <hash_proc>
c01084a1:	83 c4 10             	add    $0x10,%esp
        nr_process ++;
c01084a4:	a1 40 a0 12 c0       	mov    0xc012a040,%eax
c01084a9:	83 c0 01             	add    $0x1,%eax
c01084ac:	a3 40 a0 12 c0       	mov    %eax,0xc012a040
        list_add(&proc_list, &(proc->list_link));
c01084b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01084b4:	83 c0 58             	add    $0x58,%eax
c01084b7:	c7 45 e8 5c a1 12 c0 	movl   $0xc012a15c,-0x18(%ebp)
c01084be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01084c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01084c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01084c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01084ca:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01084cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01084d0:	8b 40 04             	mov    0x4(%eax),%eax
c01084d3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01084d6:	89 55 d8             	mov    %edx,-0x28(%ebp)
c01084d9:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01084dc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01084df:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01084e2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01084e5:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01084e8:	89 10                	mov    %edx,(%eax)
c01084ea:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01084ed:	8b 10                	mov    (%eax),%edx
c01084ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01084f2:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01084f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01084f8:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01084fb:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01084fe:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108501:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108504:	89 10                	mov    %edx,(%eax)
    }
    local_intr_restore(intr_flag);
c0108506:	83 ec 0c             	sub    $0xc,%esp
c0108509:	ff 75 ec             	pushl  -0x14(%ebp)
c010850c:	e8 b3 f8 ff ff       	call   c0107dc4 <__intr_restore>
c0108511:	83 c4 10             	add    $0x10,%esp

    wakeup_proc(proc);
c0108514:	83 ec 0c             	sub    $0xc,%esp
c0108517:	ff 75 f0             	pushl  -0x10(%ebp)
c010851a:	e8 ac 02 00 00       	call   c01087cb <wakeup_proc>
c010851f:	83 c4 10             	add    $0x10,%esp

    ret = proc->pid;
c0108522:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108525:	8b 40 04             	mov    0x4(%eax),%eax
c0108528:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010852b:	eb 04                	jmp    c0108531 <do_fork+0x129>
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
c010852d:	90                   	nop
c010852e:	eb 01                	jmp    c0108531 <do_fork+0x129>
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
    if ((proc = alloc_proc()) == NULL) {
      goto fork_out;
c0108530:	90                   	nop
    wakeup_proc(proc);

    ret = proc->pid;

fork_out:
    return ret;
c0108531:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108534:	eb 22                	jmp    c0108558 <do_fork+0x150>
    //    7. set ret vaule using child proc's pid
    if ((proc = alloc_proc()) == NULL) {
      goto fork_out;
    }
    if (setup_kstack(proc) != 0) {
      goto bad_fork_cleanup_kstack;
c0108536:	90                   	nop

fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
c0108537:	83 ec 0c             	sub    $0xc,%esp
c010853a:	ff 75 f0             	pushl  -0x10(%ebp)
c010853d:	e8 cf fd ff ff       	call   c0108311 <put_kstack>
c0108542:	83 c4 10             	add    $0x10,%esp
c0108545:	eb 01                	jmp    c0108548 <do_fork+0x140>
    }
    if (setup_kstack(proc) != 0) {
      goto bad_fork_cleanup_kstack;
    }
    if (copy_mm(clone_flags, proc) != 0) {
      goto bad_fork_cleanup_proc;
c0108547:	90                   	nop
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
c0108548:	83 ec 0c             	sub    $0xc,%esp
c010854b:	ff 75 f0             	pushl  -0x10(%ebp)
c010854e:	e8 6d c2 ff ff       	call   c01047c0 <kfree>
c0108553:	83 c4 10             	add    $0x10,%esp
    goto fork_out;
c0108556:	eb d9                	jmp    c0108531 <do_fork+0x129>
}
c0108558:	c9                   	leave  
c0108559:	c3                   	ret    

c010855a <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c010855a:	55                   	push   %ebp
c010855b:	89 e5                	mov    %esp,%ebp
c010855d:	83 ec 08             	sub    $0x8,%esp
    panic("process exit!!.\n");
c0108560:	83 ec 04             	sub    $0x4,%esp
c0108563:	68 09 b4 10 c0       	push   $0xc010b409
c0108568:	68 5f 01 00 00       	push   $0x15f
c010856d:	68 f5 b3 10 c0       	push   $0xc010b3f5
c0108572:	e8 79 7e ff ff       	call   c01003f0 <__panic>

c0108577 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c0108577:	55                   	push   %ebp
c0108578:	89 e5                	mov    %esp,%ebp
c010857a:	83 ec 08             	sub    $0x8,%esp
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
c010857d:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c0108582:	83 ec 0c             	sub    $0xc,%esp
c0108585:	50                   	push   %eax
c0108586:	e8 2f fa ff ff       	call   c0107fba <get_proc_name>
c010858b:	83 c4 10             	add    $0x10,%esp
c010858e:	89 c2                	mov    %eax,%edx
c0108590:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c0108595:	8b 40 04             	mov    0x4(%eax),%eax
c0108598:	83 ec 04             	sub    $0x4,%esp
c010859b:	52                   	push   %edx
c010859c:	50                   	push   %eax
c010859d:	68 1c b4 10 c0       	push   $0xc010b41c
c01085a2:	e8 e3 7c ff ff       	call   c010028a <cprintf>
c01085a7:	83 c4 10             	add    $0x10,%esp
    cprintf("To U: \"%s\".\n", (const char *)arg);
c01085aa:	83 ec 08             	sub    $0x8,%esp
c01085ad:	ff 75 08             	pushl  0x8(%ebp)
c01085b0:	68 42 b4 10 c0       	push   $0xc010b442
c01085b5:	e8 d0 7c ff ff       	call   c010028a <cprintf>
c01085ba:	83 c4 10             	add    $0x10,%esp
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
c01085bd:	83 ec 0c             	sub    $0xc,%esp
c01085c0:	68 4f b4 10 c0       	push   $0xc010b44f
c01085c5:	e8 c0 7c ff ff       	call   c010028a <cprintf>
c01085ca:	83 c4 10             	add    $0x10,%esp
    return 0;
c01085cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01085d2:	c9                   	leave  
c01085d3:	c3                   	ret    

c01085d4 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void
proc_init(void) {
c01085d4:	55                   	push   %ebp
c01085d5:	89 e5                	mov    %esp,%ebp
c01085d7:	83 ec 18             	sub    $0x18,%esp
c01085da:	c7 45 e8 5c a1 12 c0 	movl   $0xc012a15c,-0x18(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01085e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01085e4:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01085e7:	89 50 04             	mov    %edx,0x4(%eax)
c01085ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01085ed:	8b 50 04             	mov    0x4(%eax),%edx
c01085f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01085f3:	89 10                	mov    %edx,(%eax)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c01085f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01085fc:	eb 26                	jmp    c0108624 <proc_init+0x50>
        list_init(hash_list + i);
c01085fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108601:	c1 e0 03             	shl    $0x3,%eax
c0108604:	05 40 80 12 c0       	add    $0xc0128040,%eax
c0108609:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010860c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010860f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108612:	89 50 04             	mov    %edx,0x4(%eax)
c0108615:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108618:	8b 50 04             	mov    0x4(%eax),%edx
c010861b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010861e:	89 10                	mov    %edx,(%eax)
void
proc_init(void) {
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c0108620:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0108624:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c010862b:	7e d1                	jle    c01085fe <proc_init+0x2a>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
c010862d:	e8 9d f8 ff ff       	call   c0107ecf <alloc_proc>
c0108632:	a3 20 80 12 c0       	mov    %eax,0xc0128020
c0108637:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c010863c:	85 c0                	test   %eax,%eax
c010863e:	75 17                	jne    c0108657 <proc_init+0x83>
        panic("cannot alloc idleproc.\n");
c0108640:	83 ec 04             	sub    $0x4,%esp
c0108643:	68 6b b4 10 c0       	push   $0xc010b46b
c0108648:	68 77 01 00 00       	push   $0x177
c010864d:	68 f5 b3 10 c0       	push   $0xc010b3f5
c0108652:	e8 99 7d ff ff       	call   c01003f0 <__panic>
    }

    idleproc->pid = 0;
c0108657:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c010865c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c0108663:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0108668:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c010866e:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0108673:	ba 00 20 12 c0       	mov    $0xc0122000,%edx
c0108678:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c010867b:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0108680:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c0108687:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c010868c:	83 ec 08             	sub    $0x8,%esp
c010868f:	68 83 b4 10 c0       	push   $0xc010b483
c0108694:	50                   	push   %eax
c0108695:	e8 eb f8 ff ff       	call   c0107f85 <set_proc_name>
c010869a:	83 c4 10             	add    $0x10,%esp
    nr_process ++;
c010869d:	a1 40 a0 12 c0       	mov    0xc012a040,%eax
c01086a2:	83 c0 01             	add    $0x1,%eax
c01086a5:	a3 40 a0 12 c0       	mov    %eax,0xc012a040

    current = idleproc;
c01086aa:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c01086af:	a3 28 80 12 c0       	mov    %eax,0xc0128028

    int pid = kernel_thread(init_main, "Hello world!!", 0);
c01086b4:	83 ec 04             	sub    $0x4,%esp
c01086b7:	6a 00                	push   $0x0
c01086b9:	68 88 b4 10 c0       	push   $0xc010b488
c01086be:	68 77 85 10 c0       	push   $0xc0108577
c01086c3:	e8 a4 fb ff ff       	call   c010826c <kernel_thread>
c01086c8:	83 c4 10             	add    $0x10,%esp
c01086cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid <= 0) {
c01086ce:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01086d2:	7f 17                	jg     c01086eb <proc_init+0x117>
        panic("create init_main failed.\n");
c01086d4:	83 ec 04             	sub    $0x4,%esp
c01086d7:	68 96 b4 10 c0       	push   $0xc010b496
c01086dc:	68 85 01 00 00       	push   $0x185
c01086e1:	68 f5 b3 10 c0       	push   $0xc010b3f5
c01086e6:	e8 05 7d ff ff       	call   c01003f0 <__panic>
    }

    initproc = find_proc(pid);
c01086eb:	83 ec 0c             	sub    $0xc,%esp
c01086ee:	ff 75 ec             	pushl  -0x14(%ebp)
c01086f1:	e8 06 fb ff ff       	call   c01081fc <find_proc>
c01086f6:	83 c4 10             	add    $0x10,%esp
c01086f9:	a3 24 80 12 c0       	mov    %eax,0xc0128024
    set_proc_name(initproc, "init");
c01086fe:	a1 24 80 12 c0       	mov    0xc0128024,%eax
c0108703:	83 ec 08             	sub    $0x8,%esp
c0108706:	68 b0 b4 10 c0       	push   $0xc010b4b0
c010870b:	50                   	push   %eax
c010870c:	e8 74 f8 ff ff       	call   c0107f85 <set_proc_name>
c0108711:	83 c4 10             	add    $0x10,%esp

    assert(idleproc != NULL && idleproc->pid == 0);
c0108714:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0108719:	85 c0                	test   %eax,%eax
c010871b:	74 0c                	je     c0108729 <proc_init+0x155>
c010871d:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0108722:	8b 40 04             	mov    0x4(%eax),%eax
c0108725:	85 c0                	test   %eax,%eax
c0108727:	74 19                	je     c0108742 <proc_init+0x16e>
c0108729:	68 b8 b4 10 c0       	push   $0xc010b4b8
c010872e:	68 e0 b3 10 c0       	push   $0xc010b3e0
c0108733:	68 8b 01 00 00       	push   $0x18b
c0108738:	68 f5 b3 10 c0       	push   $0xc010b3f5
c010873d:	e8 ae 7c ff ff       	call   c01003f0 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c0108742:	a1 24 80 12 c0       	mov    0xc0128024,%eax
c0108747:	85 c0                	test   %eax,%eax
c0108749:	74 0d                	je     c0108758 <proc_init+0x184>
c010874b:	a1 24 80 12 c0       	mov    0xc0128024,%eax
c0108750:	8b 40 04             	mov    0x4(%eax),%eax
c0108753:	83 f8 01             	cmp    $0x1,%eax
c0108756:	74 19                	je     c0108771 <proc_init+0x19d>
c0108758:	68 e0 b4 10 c0       	push   $0xc010b4e0
c010875d:	68 e0 b3 10 c0       	push   $0xc010b3e0
c0108762:	68 8c 01 00 00       	push   $0x18c
c0108767:	68 f5 b3 10 c0       	push   $0xc010b3f5
c010876c:	e8 7f 7c ff ff       	call   c01003f0 <__panic>
}
c0108771:	90                   	nop
c0108772:	c9                   	leave  
c0108773:	c3                   	ret    

c0108774 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c0108774:	55                   	push   %ebp
c0108775:	89 e5                	mov    %esp,%ebp
c0108777:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c010877a:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c010877f:	8b 40 10             	mov    0x10(%eax),%eax
c0108782:	85 c0                	test   %eax,%eax
c0108784:	74 f4                	je     c010877a <cpu_idle+0x6>
            schedule();
c0108786:	e8 7c 00 00 00       	call   c0108807 <schedule>
        }
    }
c010878b:	eb ed                	jmp    c010877a <cpu_idle+0x6>

c010878d <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c010878d:	55                   	push   %ebp
c010878e:	89 e5                	mov    %esp,%ebp
c0108790:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0108793:	9c                   	pushf  
c0108794:	58                   	pop    %eax
c0108795:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0108798:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010879b:	25 00 02 00 00       	and    $0x200,%eax
c01087a0:	85 c0                	test   %eax,%eax
c01087a2:	74 0c                	je     c01087b0 <__intr_save+0x23>
        intr_disable();
c01087a4:	e8 69 98 ff ff       	call   c0102012 <intr_disable>
        return 1;
c01087a9:	b8 01 00 00 00       	mov    $0x1,%eax
c01087ae:	eb 05                	jmp    c01087b5 <__intr_save+0x28>
    }
    return 0;
c01087b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01087b5:	c9                   	leave  
c01087b6:	c3                   	ret    

c01087b7 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01087b7:	55                   	push   %ebp
c01087b8:	89 e5                	mov    %esp,%ebp
c01087ba:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01087bd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01087c1:	74 05                	je     c01087c8 <__intr_restore+0x11>
        intr_enable();
c01087c3:	e8 43 98 ff ff       	call   c010200b <intr_enable>
    }
}
c01087c8:	90                   	nop
c01087c9:	c9                   	leave  
c01087ca:	c3                   	ret    

c01087cb <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
c01087cb:	55                   	push   %ebp
c01087cc:	89 e5                	mov    %esp,%ebp
c01087ce:	83 ec 08             	sub    $0x8,%esp
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
c01087d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01087d4:	8b 00                	mov    (%eax),%eax
c01087d6:	83 f8 03             	cmp    $0x3,%eax
c01087d9:	74 0a                	je     c01087e5 <wakeup_proc+0x1a>
c01087db:	8b 45 08             	mov    0x8(%ebp),%eax
c01087de:	8b 00                	mov    (%eax),%eax
c01087e0:	83 f8 02             	cmp    $0x2,%eax
c01087e3:	75 16                	jne    c01087fb <wakeup_proc+0x30>
c01087e5:	68 08 b5 10 c0       	push   $0xc010b508
c01087ea:	68 43 b5 10 c0       	push   $0xc010b543
c01087ef:	6a 09                	push   $0x9
c01087f1:	68 58 b5 10 c0       	push   $0xc010b558
c01087f6:	e8 f5 7b ff ff       	call   c01003f0 <__panic>
    proc->state = PROC_RUNNABLE;
c01087fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01087fe:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
}
c0108804:	90                   	nop
c0108805:	c9                   	leave  
c0108806:	c3                   	ret    

c0108807 <schedule>:

void
schedule(void) {
c0108807:	55                   	push   %ebp
c0108808:	89 e5                	mov    %esp,%ebp
c010880a:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
c010880d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    local_intr_save(intr_flag);
c0108814:	e8 74 ff ff ff       	call   c010878d <__intr_save>
c0108819:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        current->need_resched = 0;
c010881c:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c0108821:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
c0108828:	8b 15 28 80 12 c0    	mov    0xc0128028,%edx
c010882e:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0108833:	39 c2                	cmp    %eax,%edx
c0108835:	74 0a                	je     c0108841 <schedule+0x3a>
c0108837:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c010883c:	83 c0 58             	add    $0x58,%eax
c010883f:	eb 05                	jmp    c0108846 <schedule+0x3f>
c0108841:	b8 5c a1 12 c0       	mov    $0xc012a15c,%eax
c0108846:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = last;
c0108849:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010884c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010884f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108852:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0108855:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108858:	8b 40 04             	mov    0x4(%eax),%eax
        do {
            if ((le = list_next(le)) != &proc_list) {
c010885b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010885e:	81 7d f4 5c a1 12 c0 	cmpl   $0xc012a15c,-0xc(%ebp)
c0108865:	74 13                	je     c010887a <schedule+0x73>
                next = le2proc(le, list_link);
c0108867:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010886a:	83 e8 58             	sub    $0x58,%eax
c010886d:	89 45 f0             	mov    %eax,-0x10(%ebp)
                if (next->state == PROC_RUNNABLE) {
c0108870:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108873:	8b 00                	mov    (%eax),%eax
c0108875:	83 f8 02             	cmp    $0x2,%eax
c0108878:	74 0a                	je     c0108884 <schedule+0x7d>
                    break;
                }
            }
        } while (le != last);
c010887a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010887d:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0108880:	75 cd                	jne    c010884f <schedule+0x48>
c0108882:	eb 01                	jmp    c0108885 <schedule+0x7e>
        le = last;
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
                    break;
c0108884:	90                   	nop
                }
            }
        } while (le != last);
        if (next == NULL || next->state != PROC_RUNNABLE) {
c0108885:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108889:	74 0a                	je     c0108895 <schedule+0x8e>
c010888b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010888e:	8b 00                	mov    (%eax),%eax
c0108890:	83 f8 02             	cmp    $0x2,%eax
c0108893:	74 08                	je     c010889d <schedule+0x96>
            next = idleproc;
c0108895:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c010889a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        next->runs ++;
c010889d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01088a0:	8b 40 08             	mov    0x8(%eax),%eax
c01088a3:	8d 50 01             	lea    0x1(%eax),%edx
c01088a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01088a9:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c01088ac:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c01088b1:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01088b4:	74 0e                	je     c01088c4 <schedule+0xbd>
            proc_run(next);
c01088b6:	83 ec 0c             	sub    $0xc,%esp
c01088b9:	ff 75 f0             	pushl  -0x10(%ebp)
c01088bc:	e8 26 f8 ff ff       	call   c01080e7 <proc_run>
c01088c1:	83 c4 10             	add    $0x10,%esp
        }
    }
    local_intr_restore(intr_flag);
c01088c4:	83 ec 0c             	sub    $0xc,%esp
c01088c7:	ff 75 ec             	pushl  -0x14(%ebp)
c01088ca:	e8 e8 fe ff ff       	call   c01087b7 <__intr_restore>
c01088cf:	83 c4 10             	add    $0x10,%esp
}
c01088d2:	90                   	nop
c01088d3:	c9                   	leave  
c01088d4:	c3                   	ret    

c01088d5 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c01088d5:	55                   	push   %ebp
c01088d6:	89 e5                	mov    %esp,%ebp
c01088d8:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01088db:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c01088e2:	eb 04                	jmp    c01088e8 <strlen+0x13>
        cnt ++;
c01088e4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c01088e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01088eb:	8d 50 01             	lea    0x1(%eax),%edx
c01088ee:	89 55 08             	mov    %edx,0x8(%ebp)
c01088f1:	0f b6 00             	movzbl (%eax),%eax
c01088f4:	84 c0                	test   %al,%al
c01088f6:	75 ec                	jne    c01088e4 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c01088f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01088fb:	c9                   	leave  
c01088fc:	c3                   	ret    

c01088fd <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c01088fd:	55                   	push   %ebp
c01088fe:	89 e5                	mov    %esp,%ebp
c0108900:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0108903:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010890a:	eb 04                	jmp    c0108910 <strnlen+0x13>
        cnt ++;
c010890c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c0108910:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108913:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108916:	73 10                	jae    c0108928 <strnlen+0x2b>
c0108918:	8b 45 08             	mov    0x8(%ebp),%eax
c010891b:	8d 50 01             	lea    0x1(%eax),%edx
c010891e:	89 55 08             	mov    %edx,0x8(%ebp)
c0108921:	0f b6 00             	movzbl (%eax),%eax
c0108924:	84 c0                	test   %al,%al
c0108926:	75 e4                	jne    c010890c <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0108928:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010892b:	c9                   	leave  
c010892c:	c3                   	ret    

c010892d <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010892d:	55                   	push   %ebp
c010892e:	89 e5                	mov    %esp,%ebp
c0108930:	57                   	push   %edi
c0108931:	56                   	push   %esi
c0108932:	83 ec 20             	sub    $0x20,%esp
c0108935:	8b 45 08             	mov    0x8(%ebp),%eax
c0108938:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010893b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010893e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0108941:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108944:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108947:	89 d1                	mov    %edx,%ecx
c0108949:	89 c2                	mov    %eax,%edx
c010894b:	89 ce                	mov    %ecx,%esi
c010894d:	89 d7                	mov    %edx,%edi
c010894f:	ac                   	lods   %ds:(%esi),%al
c0108950:	aa                   	stos   %al,%es:(%edi)
c0108951:	84 c0                	test   %al,%al
c0108953:	75 fa                	jne    c010894f <strcpy+0x22>
c0108955:	89 fa                	mov    %edi,%edx
c0108957:	89 f1                	mov    %esi,%ecx
c0108959:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010895c:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010895f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0108962:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c0108965:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0108966:	83 c4 20             	add    $0x20,%esp
c0108969:	5e                   	pop    %esi
c010896a:	5f                   	pop    %edi
c010896b:	5d                   	pop    %ebp
c010896c:	c3                   	ret    

c010896d <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010896d:	55                   	push   %ebp
c010896e:	89 e5                	mov    %esp,%ebp
c0108970:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0108973:	8b 45 08             	mov    0x8(%ebp),%eax
c0108976:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0108979:	eb 21                	jmp    c010899c <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c010897b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010897e:	0f b6 10             	movzbl (%eax),%edx
c0108981:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108984:	88 10                	mov    %dl,(%eax)
c0108986:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108989:	0f b6 00             	movzbl (%eax),%eax
c010898c:	84 c0                	test   %al,%al
c010898e:	74 04                	je     c0108994 <strncpy+0x27>
            src ++;
c0108990:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c0108994:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0108998:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c010899c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01089a0:	75 d9                	jne    c010897b <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c01089a2:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01089a5:	c9                   	leave  
c01089a6:	c3                   	ret    

c01089a7 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c01089a7:	55                   	push   %ebp
c01089a8:	89 e5                	mov    %esp,%ebp
c01089aa:	57                   	push   %edi
c01089ab:	56                   	push   %esi
c01089ac:	83 ec 20             	sub    $0x20,%esp
c01089af:	8b 45 08             	mov    0x8(%ebp),%eax
c01089b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01089b5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01089b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c01089bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01089be:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01089c1:	89 d1                	mov    %edx,%ecx
c01089c3:	89 c2                	mov    %eax,%edx
c01089c5:	89 ce                	mov    %ecx,%esi
c01089c7:	89 d7                	mov    %edx,%edi
c01089c9:	ac                   	lods   %ds:(%esi),%al
c01089ca:	ae                   	scas   %es:(%edi),%al
c01089cb:	75 08                	jne    c01089d5 <strcmp+0x2e>
c01089cd:	84 c0                	test   %al,%al
c01089cf:	75 f8                	jne    c01089c9 <strcmp+0x22>
c01089d1:	31 c0                	xor    %eax,%eax
c01089d3:	eb 04                	jmp    c01089d9 <strcmp+0x32>
c01089d5:	19 c0                	sbb    %eax,%eax
c01089d7:	0c 01                	or     $0x1,%al
c01089d9:	89 fa                	mov    %edi,%edx
c01089db:	89 f1                	mov    %esi,%ecx
c01089dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01089e0:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01089e3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c01089e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c01089e9:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c01089ea:	83 c4 20             	add    $0x20,%esp
c01089ed:	5e                   	pop    %esi
c01089ee:	5f                   	pop    %edi
c01089ef:	5d                   	pop    %ebp
c01089f0:	c3                   	ret    

c01089f1 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c01089f1:	55                   	push   %ebp
c01089f2:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01089f4:	eb 0c                	jmp    c0108a02 <strncmp+0x11>
        n --, s1 ++, s2 ++;
c01089f6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01089fa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01089fe:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0108a02:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108a06:	74 1a                	je     c0108a22 <strncmp+0x31>
c0108a08:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a0b:	0f b6 00             	movzbl (%eax),%eax
c0108a0e:	84 c0                	test   %al,%al
c0108a10:	74 10                	je     c0108a22 <strncmp+0x31>
c0108a12:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a15:	0f b6 10             	movzbl (%eax),%edx
c0108a18:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108a1b:	0f b6 00             	movzbl (%eax),%eax
c0108a1e:	38 c2                	cmp    %al,%dl
c0108a20:	74 d4                	je     c01089f6 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0108a22:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108a26:	74 18                	je     c0108a40 <strncmp+0x4f>
c0108a28:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a2b:	0f b6 00             	movzbl (%eax),%eax
c0108a2e:	0f b6 d0             	movzbl %al,%edx
c0108a31:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108a34:	0f b6 00             	movzbl (%eax),%eax
c0108a37:	0f b6 c0             	movzbl %al,%eax
c0108a3a:	29 c2                	sub    %eax,%edx
c0108a3c:	89 d0                	mov    %edx,%eax
c0108a3e:	eb 05                	jmp    c0108a45 <strncmp+0x54>
c0108a40:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108a45:	5d                   	pop    %ebp
c0108a46:	c3                   	ret    

c0108a47 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0108a47:	55                   	push   %ebp
c0108a48:	89 e5                	mov    %esp,%ebp
c0108a4a:	83 ec 04             	sub    $0x4,%esp
c0108a4d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108a50:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0108a53:	eb 14                	jmp    c0108a69 <strchr+0x22>
        if (*s == c) {
c0108a55:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a58:	0f b6 00             	movzbl (%eax),%eax
c0108a5b:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0108a5e:	75 05                	jne    c0108a65 <strchr+0x1e>
            return (char *)s;
c0108a60:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a63:	eb 13                	jmp    c0108a78 <strchr+0x31>
        }
        s ++;
c0108a65:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c0108a69:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a6c:	0f b6 00             	movzbl (%eax),%eax
c0108a6f:	84 c0                	test   %al,%al
c0108a71:	75 e2                	jne    c0108a55 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c0108a73:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108a78:	c9                   	leave  
c0108a79:	c3                   	ret    

c0108a7a <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0108a7a:	55                   	push   %ebp
c0108a7b:	89 e5                	mov    %esp,%ebp
c0108a7d:	83 ec 04             	sub    $0x4,%esp
c0108a80:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108a83:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0108a86:	eb 0f                	jmp    c0108a97 <strfind+0x1d>
        if (*s == c) {
c0108a88:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a8b:	0f b6 00             	movzbl (%eax),%eax
c0108a8e:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0108a91:	74 10                	je     c0108aa3 <strfind+0x29>
            break;
        }
        s ++;
c0108a93:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0108a97:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a9a:	0f b6 00             	movzbl (%eax),%eax
c0108a9d:	84 c0                	test   %al,%al
c0108a9f:	75 e7                	jne    c0108a88 <strfind+0xe>
c0108aa1:	eb 01                	jmp    c0108aa4 <strfind+0x2a>
        if (*s == c) {
            break;
c0108aa3:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
c0108aa4:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0108aa7:	c9                   	leave  
c0108aa8:	c3                   	ret    

c0108aa9 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0108aa9:	55                   	push   %ebp
c0108aaa:	89 e5                	mov    %esp,%ebp
c0108aac:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0108aaf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0108ab6:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0108abd:	eb 04                	jmp    c0108ac3 <strtol+0x1a>
        s ++;
c0108abf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0108ac3:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ac6:	0f b6 00             	movzbl (%eax),%eax
c0108ac9:	3c 20                	cmp    $0x20,%al
c0108acb:	74 f2                	je     c0108abf <strtol+0x16>
c0108acd:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ad0:	0f b6 00             	movzbl (%eax),%eax
c0108ad3:	3c 09                	cmp    $0x9,%al
c0108ad5:	74 e8                	je     c0108abf <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c0108ad7:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ada:	0f b6 00             	movzbl (%eax),%eax
c0108add:	3c 2b                	cmp    $0x2b,%al
c0108adf:	75 06                	jne    c0108ae7 <strtol+0x3e>
        s ++;
c0108ae1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0108ae5:	eb 15                	jmp    c0108afc <strtol+0x53>
    }
    else if (*s == '-') {
c0108ae7:	8b 45 08             	mov    0x8(%ebp),%eax
c0108aea:	0f b6 00             	movzbl (%eax),%eax
c0108aed:	3c 2d                	cmp    $0x2d,%al
c0108aef:	75 0b                	jne    c0108afc <strtol+0x53>
        s ++, neg = 1;
c0108af1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0108af5:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0108afc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108b00:	74 06                	je     c0108b08 <strtol+0x5f>
c0108b02:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0108b06:	75 24                	jne    c0108b2c <strtol+0x83>
c0108b08:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b0b:	0f b6 00             	movzbl (%eax),%eax
c0108b0e:	3c 30                	cmp    $0x30,%al
c0108b10:	75 1a                	jne    c0108b2c <strtol+0x83>
c0108b12:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b15:	83 c0 01             	add    $0x1,%eax
c0108b18:	0f b6 00             	movzbl (%eax),%eax
c0108b1b:	3c 78                	cmp    $0x78,%al
c0108b1d:	75 0d                	jne    c0108b2c <strtol+0x83>
        s += 2, base = 16;
c0108b1f:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0108b23:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0108b2a:	eb 2a                	jmp    c0108b56 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c0108b2c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108b30:	75 17                	jne    c0108b49 <strtol+0xa0>
c0108b32:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b35:	0f b6 00             	movzbl (%eax),%eax
c0108b38:	3c 30                	cmp    $0x30,%al
c0108b3a:	75 0d                	jne    c0108b49 <strtol+0xa0>
        s ++, base = 8;
c0108b3c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0108b40:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0108b47:	eb 0d                	jmp    c0108b56 <strtol+0xad>
    }
    else if (base == 0) {
c0108b49:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108b4d:	75 07                	jne    c0108b56 <strtol+0xad>
        base = 10;
c0108b4f:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0108b56:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b59:	0f b6 00             	movzbl (%eax),%eax
c0108b5c:	3c 2f                	cmp    $0x2f,%al
c0108b5e:	7e 1b                	jle    c0108b7b <strtol+0xd2>
c0108b60:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b63:	0f b6 00             	movzbl (%eax),%eax
c0108b66:	3c 39                	cmp    $0x39,%al
c0108b68:	7f 11                	jg     c0108b7b <strtol+0xd2>
            dig = *s - '0';
c0108b6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b6d:	0f b6 00             	movzbl (%eax),%eax
c0108b70:	0f be c0             	movsbl %al,%eax
c0108b73:	83 e8 30             	sub    $0x30,%eax
c0108b76:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108b79:	eb 48                	jmp    c0108bc3 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0108b7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b7e:	0f b6 00             	movzbl (%eax),%eax
c0108b81:	3c 60                	cmp    $0x60,%al
c0108b83:	7e 1b                	jle    c0108ba0 <strtol+0xf7>
c0108b85:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b88:	0f b6 00             	movzbl (%eax),%eax
c0108b8b:	3c 7a                	cmp    $0x7a,%al
c0108b8d:	7f 11                	jg     c0108ba0 <strtol+0xf7>
            dig = *s - 'a' + 10;
c0108b8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b92:	0f b6 00             	movzbl (%eax),%eax
c0108b95:	0f be c0             	movsbl %al,%eax
c0108b98:	83 e8 57             	sub    $0x57,%eax
c0108b9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108b9e:	eb 23                	jmp    c0108bc3 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0108ba0:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ba3:	0f b6 00             	movzbl (%eax),%eax
c0108ba6:	3c 40                	cmp    $0x40,%al
c0108ba8:	7e 3c                	jle    c0108be6 <strtol+0x13d>
c0108baa:	8b 45 08             	mov    0x8(%ebp),%eax
c0108bad:	0f b6 00             	movzbl (%eax),%eax
c0108bb0:	3c 5a                	cmp    $0x5a,%al
c0108bb2:	7f 32                	jg     c0108be6 <strtol+0x13d>
            dig = *s - 'A' + 10;
c0108bb4:	8b 45 08             	mov    0x8(%ebp),%eax
c0108bb7:	0f b6 00             	movzbl (%eax),%eax
c0108bba:	0f be c0             	movsbl %al,%eax
c0108bbd:	83 e8 37             	sub    $0x37,%eax
c0108bc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0108bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108bc6:	3b 45 10             	cmp    0x10(%ebp),%eax
c0108bc9:	7d 1a                	jge    c0108be5 <strtol+0x13c>
            break;
        }
        s ++, val = (val * base) + dig;
c0108bcb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0108bcf:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108bd2:	0f af 45 10          	imul   0x10(%ebp),%eax
c0108bd6:	89 c2                	mov    %eax,%edx
c0108bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108bdb:	01 d0                	add    %edx,%eax
c0108bdd:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c0108be0:	e9 71 ff ff ff       	jmp    c0108b56 <strtol+0xad>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
c0108be5:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
c0108be6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108bea:	74 08                	je     c0108bf4 <strtol+0x14b>
        *endptr = (char *) s;
c0108bec:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108bef:	8b 55 08             	mov    0x8(%ebp),%edx
c0108bf2:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0108bf4:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108bf8:	74 07                	je     c0108c01 <strtol+0x158>
c0108bfa:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108bfd:	f7 d8                	neg    %eax
c0108bff:	eb 03                	jmp    c0108c04 <strtol+0x15b>
c0108c01:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0108c04:	c9                   	leave  
c0108c05:	c3                   	ret    

c0108c06 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0108c06:	55                   	push   %ebp
c0108c07:	89 e5                	mov    %esp,%ebp
c0108c09:	57                   	push   %edi
c0108c0a:	83 ec 24             	sub    $0x24,%esp
c0108c0d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108c10:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0108c13:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0108c17:	8b 55 08             	mov    0x8(%ebp),%edx
c0108c1a:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0108c1d:	88 45 f7             	mov    %al,-0x9(%ebp)
c0108c20:	8b 45 10             	mov    0x10(%ebp),%eax
c0108c23:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0108c26:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0108c29:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0108c2d:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0108c30:	89 d7                	mov    %edx,%edi
c0108c32:	f3 aa                	rep stos %al,%es:(%edi)
c0108c34:	89 fa                	mov    %edi,%edx
c0108c36:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0108c39:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0108c3c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108c3f:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0108c40:	83 c4 24             	add    $0x24,%esp
c0108c43:	5f                   	pop    %edi
c0108c44:	5d                   	pop    %ebp
c0108c45:	c3                   	ret    

c0108c46 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0108c46:	55                   	push   %ebp
c0108c47:	89 e5                	mov    %esp,%ebp
c0108c49:	57                   	push   %edi
c0108c4a:	56                   	push   %esi
c0108c4b:	53                   	push   %ebx
c0108c4c:	83 ec 30             	sub    $0x30,%esp
c0108c4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c52:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108c55:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108c58:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108c5b:	8b 45 10             	mov    0x10(%ebp),%eax
c0108c5e:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0108c61:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108c64:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108c67:	73 42                	jae    c0108cab <memmove+0x65>
c0108c69:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108c6c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108c6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108c72:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108c75:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c78:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0108c7b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108c7e:	c1 e8 02             	shr    $0x2,%eax
c0108c81:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0108c83:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108c86:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108c89:	89 d7                	mov    %edx,%edi
c0108c8b:	89 c6                	mov    %eax,%esi
c0108c8d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0108c8f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0108c92:	83 e1 03             	and    $0x3,%ecx
c0108c95:	74 02                	je     c0108c99 <memmove+0x53>
c0108c97:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108c99:	89 f0                	mov    %esi,%eax
c0108c9b:	89 fa                	mov    %edi,%edx
c0108c9d:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0108ca0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108ca3:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0108ca6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c0108ca9:	eb 36                	jmp    c0108ce1 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0108cab:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108cae:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108cb1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108cb4:	01 c2                	add    %eax,%edx
c0108cb6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108cb9:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0108cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108cbf:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c0108cc2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108cc5:	89 c1                	mov    %eax,%ecx
c0108cc7:	89 d8                	mov    %ebx,%eax
c0108cc9:	89 d6                	mov    %edx,%esi
c0108ccb:	89 c7                	mov    %eax,%edi
c0108ccd:	fd                   	std    
c0108cce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108cd0:	fc                   	cld    
c0108cd1:	89 f8                	mov    %edi,%eax
c0108cd3:	89 f2                	mov    %esi,%edx
c0108cd5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0108cd8:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0108cdb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c0108cde:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0108ce1:	83 c4 30             	add    $0x30,%esp
c0108ce4:	5b                   	pop    %ebx
c0108ce5:	5e                   	pop    %esi
c0108ce6:	5f                   	pop    %edi
c0108ce7:	5d                   	pop    %ebp
c0108ce8:	c3                   	ret    

c0108ce9 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0108ce9:	55                   	push   %ebp
c0108cea:	89 e5                	mov    %esp,%ebp
c0108cec:	57                   	push   %edi
c0108ced:	56                   	push   %esi
c0108cee:	83 ec 20             	sub    $0x20,%esp
c0108cf1:	8b 45 08             	mov    0x8(%ebp),%eax
c0108cf4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108cf7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108cfa:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108cfd:	8b 45 10             	mov    0x10(%ebp),%eax
c0108d00:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0108d03:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108d06:	c1 e8 02             	shr    $0x2,%eax
c0108d09:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0108d0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108d0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108d11:	89 d7                	mov    %edx,%edi
c0108d13:	89 c6                	mov    %eax,%esi
c0108d15:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0108d17:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0108d1a:	83 e1 03             	and    $0x3,%ecx
c0108d1d:	74 02                	je     c0108d21 <memcpy+0x38>
c0108d1f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108d21:	89 f0                	mov    %esi,%eax
c0108d23:	89 fa                	mov    %edi,%edx
c0108d25:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0108d28:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108d2b:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0108d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c0108d31:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0108d32:	83 c4 20             	add    $0x20,%esp
c0108d35:	5e                   	pop    %esi
c0108d36:	5f                   	pop    %edi
c0108d37:	5d                   	pop    %ebp
c0108d38:	c3                   	ret    

c0108d39 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0108d39:	55                   	push   %ebp
c0108d3a:	89 e5                	mov    %esp,%ebp
c0108d3c:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0108d3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d42:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0108d45:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108d48:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0108d4b:	eb 30                	jmp    c0108d7d <memcmp+0x44>
        if (*s1 != *s2) {
c0108d4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108d50:	0f b6 10             	movzbl (%eax),%edx
c0108d53:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108d56:	0f b6 00             	movzbl (%eax),%eax
c0108d59:	38 c2                	cmp    %al,%dl
c0108d5b:	74 18                	je     c0108d75 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0108d5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108d60:	0f b6 00             	movzbl (%eax),%eax
c0108d63:	0f b6 d0             	movzbl %al,%edx
c0108d66:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108d69:	0f b6 00             	movzbl (%eax),%eax
c0108d6c:	0f b6 c0             	movzbl %al,%eax
c0108d6f:	29 c2                	sub    %eax,%edx
c0108d71:	89 d0                	mov    %edx,%eax
c0108d73:	eb 1a                	jmp    c0108d8f <memcmp+0x56>
        }
        s1 ++, s2 ++;
c0108d75:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0108d79:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0108d7d:	8b 45 10             	mov    0x10(%ebp),%eax
c0108d80:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108d83:	89 55 10             	mov    %edx,0x10(%ebp)
c0108d86:	85 c0                	test   %eax,%eax
c0108d88:	75 c3                	jne    c0108d4d <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0108d8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108d8f:	c9                   	leave  
c0108d90:	c3                   	ret    

c0108d91 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0108d91:	55                   	push   %ebp
c0108d92:	89 e5                	mov    %esp,%ebp
c0108d94:	83 ec 38             	sub    $0x38,%esp
c0108d97:	8b 45 10             	mov    0x10(%ebp),%eax
c0108d9a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0108d9d:	8b 45 14             	mov    0x14(%ebp),%eax
c0108da0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0108da3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108da6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108da9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108dac:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0108daf:	8b 45 18             	mov    0x18(%ebp),%eax
c0108db2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108db5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108db8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108dbb:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108dbe:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0108dc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108dc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108dc7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108dcb:	74 1c                	je     c0108de9 <printnum+0x58>
c0108dcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108dd0:	ba 00 00 00 00       	mov    $0x0,%edx
c0108dd5:	f7 75 e4             	divl   -0x1c(%ebp)
c0108dd8:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0108ddb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108dde:	ba 00 00 00 00       	mov    $0x0,%edx
c0108de3:	f7 75 e4             	divl   -0x1c(%ebp)
c0108de6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108de9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108dec:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108def:	f7 75 e4             	divl   -0x1c(%ebp)
c0108df2:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108df5:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0108df8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108dfb:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108dfe:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108e01:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0108e04:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108e07:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0108e0a:	8b 45 18             	mov    0x18(%ebp),%eax
c0108e0d:	ba 00 00 00 00       	mov    $0x0,%edx
c0108e12:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0108e15:	77 41                	ja     c0108e58 <printnum+0xc7>
c0108e17:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0108e1a:	72 05                	jb     c0108e21 <printnum+0x90>
c0108e1c:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0108e1f:	77 37                	ja     c0108e58 <printnum+0xc7>
        printnum(putch, putdat, result, base, width - 1, padc);
c0108e21:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0108e24:	83 e8 01             	sub    $0x1,%eax
c0108e27:	83 ec 04             	sub    $0x4,%esp
c0108e2a:	ff 75 20             	pushl  0x20(%ebp)
c0108e2d:	50                   	push   %eax
c0108e2e:	ff 75 18             	pushl  0x18(%ebp)
c0108e31:	ff 75 ec             	pushl  -0x14(%ebp)
c0108e34:	ff 75 e8             	pushl  -0x18(%ebp)
c0108e37:	ff 75 0c             	pushl  0xc(%ebp)
c0108e3a:	ff 75 08             	pushl  0x8(%ebp)
c0108e3d:	e8 4f ff ff ff       	call   c0108d91 <printnum>
c0108e42:	83 c4 20             	add    $0x20,%esp
c0108e45:	eb 1b                	jmp    c0108e62 <printnum+0xd1>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0108e47:	83 ec 08             	sub    $0x8,%esp
c0108e4a:	ff 75 0c             	pushl  0xc(%ebp)
c0108e4d:	ff 75 20             	pushl  0x20(%ebp)
c0108e50:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e53:	ff d0                	call   *%eax
c0108e55:	83 c4 10             	add    $0x10,%esp
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c0108e58:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c0108e5c:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0108e60:	7f e5                	jg     c0108e47 <printnum+0xb6>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0108e62:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108e65:	05 f0 b5 10 c0       	add    $0xc010b5f0,%eax
c0108e6a:	0f b6 00             	movzbl (%eax),%eax
c0108e6d:	0f be c0             	movsbl %al,%eax
c0108e70:	83 ec 08             	sub    $0x8,%esp
c0108e73:	ff 75 0c             	pushl  0xc(%ebp)
c0108e76:	50                   	push   %eax
c0108e77:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e7a:	ff d0                	call   *%eax
c0108e7c:	83 c4 10             	add    $0x10,%esp
}
c0108e7f:	90                   	nop
c0108e80:	c9                   	leave  
c0108e81:	c3                   	ret    

c0108e82 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0108e82:	55                   	push   %ebp
c0108e83:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0108e85:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0108e89:	7e 14                	jle    c0108e9f <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0108e8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e8e:	8b 00                	mov    (%eax),%eax
c0108e90:	8d 48 08             	lea    0x8(%eax),%ecx
c0108e93:	8b 55 08             	mov    0x8(%ebp),%edx
c0108e96:	89 0a                	mov    %ecx,(%edx)
c0108e98:	8b 50 04             	mov    0x4(%eax),%edx
c0108e9b:	8b 00                	mov    (%eax),%eax
c0108e9d:	eb 30                	jmp    c0108ecf <getuint+0x4d>
    }
    else if (lflag) {
c0108e9f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108ea3:	74 16                	je     c0108ebb <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0108ea5:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ea8:	8b 00                	mov    (%eax),%eax
c0108eaa:	8d 48 04             	lea    0x4(%eax),%ecx
c0108ead:	8b 55 08             	mov    0x8(%ebp),%edx
c0108eb0:	89 0a                	mov    %ecx,(%edx)
c0108eb2:	8b 00                	mov    (%eax),%eax
c0108eb4:	ba 00 00 00 00       	mov    $0x0,%edx
c0108eb9:	eb 14                	jmp    c0108ecf <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0108ebb:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ebe:	8b 00                	mov    (%eax),%eax
c0108ec0:	8d 48 04             	lea    0x4(%eax),%ecx
c0108ec3:	8b 55 08             	mov    0x8(%ebp),%edx
c0108ec6:	89 0a                	mov    %ecx,(%edx)
c0108ec8:	8b 00                	mov    (%eax),%eax
c0108eca:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0108ecf:	5d                   	pop    %ebp
c0108ed0:	c3                   	ret    

c0108ed1 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0108ed1:	55                   	push   %ebp
c0108ed2:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0108ed4:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0108ed8:	7e 14                	jle    c0108eee <getint+0x1d>
        return va_arg(*ap, long long);
c0108eda:	8b 45 08             	mov    0x8(%ebp),%eax
c0108edd:	8b 00                	mov    (%eax),%eax
c0108edf:	8d 48 08             	lea    0x8(%eax),%ecx
c0108ee2:	8b 55 08             	mov    0x8(%ebp),%edx
c0108ee5:	89 0a                	mov    %ecx,(%edx)
c0108ee7:	8b 50 04             	mov    0x4(%eax),%edx
c0108eea:	8b 00                	mov    (%eax),%eax
c0108eec:	eb 28                	jmp    c0108f16 <getint+0x45>
    }
    else if (lflag) {
c0108eee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108ef2:	74 12                	je     c0108f06 <getint+0x35>
        return va_arg(*ap, long);
c0108ef4:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ef7:	8b 00                	mov    (%eax),%eax
c0108ef9:	8d 48 04             	lea    0x4(%eax),%ecx
c0108efc:	8b 55 08             	mov    0x8(%ebp),%edx
c0108eff:	89 0a                	mov    %ecx,(%edx)
c0108f01:	8b 00                	mov    (%eax),%eax
c0108f03:	99                   	cltd   
c0108f04:	eb 10                	jmp    c0108f16 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0108f06:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f09:	8b 00                	mov    (%eax),%eax
c0108f0b:	8d 48 04             	lea    0x4(%eax),%ecx
c0108f0e:	8b 55 08             	mov    0x8(%ebp),%edx
c0108f11:	89 0a                	mov    %ecx,(%edx)
c0108f13:	8b 00                	mov    (%eax),%eax
c0108f15:	99                   	cltd   
    }
}
c0108f16:	5d                   	pop    %ebp
c0108f17:	c3                   	ret    

c0108f18 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0108f18:	55                   	push   %ebp
c0108f19:	89 e5                	mov    %esp,%ebp
c0108f1b:	83 ec 18             	sub    $0x18,%esp
    va_list ap;

    va_start(ap, fmt);
c0108f1e:	8d 45 14             	lea    0x14(%ebp),%eax
c0108f21:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0108f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108f27:	50                   	push   %eax
c0108f28:	ff 75 10             	pushl  0x10(%ebp)
c0108f2b:	ff 75 0c             	pushl  0xc(%ebp)
c0108f2e:	ff 75 08             	pushl  0x8(%ebp)
c0108f31:	e8 06 00 00 00       	call   c0108f3c <vprintfmt>
c0108f36:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
c0108f39:	90                   	nop
c0108f3a:	c9                   	leave  
c0108f3b:	c3                   	ret    

c0108f3c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0108f3c:	55                   	push   %ebp
c0108f3d:	89 e5                	mov    %esp,%ebp
c0108f3f:	56                   	push   %esi
c0108f40:	53                   	push   %ebx
c0108f41:	83 ec 20             	sub    $0x20,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0108f44:	eb 17                	jmp    c0108f5d <vprintfmt+0x21>
            if (ch == '\0') {
c0108f46:	85 db                	test   %ebx,%ebx
c0108f48:	0f 84 8e 03 00 00    	je     c01092dc <vprintfmt+0x3a0>
                return;
            }
            putch(ch, putdat);
c0108f4e:	83 ec 08             	sub    $0x8,%esp
c0108f51:	ff 75 0c             	pushl  0xc(%ebp)
c0108f54:	53                   	push   %ebx
c0108f55:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f58:	ff d0                	call   *%eax
c0108f5a:	83 c4 10             	add    $0x10,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0108f5d:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f60:	8d 50 01             	lea    0x1(%eax),%edx
c0108f63:	89 55 10             	mov    %edx,0x10(%ebp)
c0108f66:	0f b6 00             	movzbl (%eax),%eax
c0108f69:	0f b6 d8             	movzbl %al,%ebx
c0108f6c:	83 fb 25             	cmp    $0x25,%ebx
c0108f6f:	75 d5                	jne    c0108f46 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c0108f71:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0108f75:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0108f7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108f7f:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0108f82:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0108f89:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108f8c:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0108f8f:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f92:	8d 50 01             	lea    0x1(%eax),%edx
c0108f95:	89 55 10             	mov    %edx,0x10(%ebp)
c0108f98:	0f b6 00             	movzbl (%eax),%eax
c0108f9b:	0f b6 d8             	movzbl %al,%ebx
c0108f9e:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0108fa1:	83 f8 55             	cmp    $0x55,%eax
c0108fa4:	0f 87 05 03 00 00    	ja     c01092af <vprintfmt+0x373>
c0108faa:	8b 04 85 14 b6 10 c0 	mov    -0x3fef49ec(,%eax,4),%eax
c0108fb1:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0108fb3:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0108fb7:	eb d6                	jmp    c0108f8f <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0108fb9:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0108fbd:	eb d0                	jmp    c0108f8f <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0108fbf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0108fc6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108fc9:	89 d0                	mov    %edx,%eax
c0108fcb:	c1 e0 02             	shl    $0x2,%eax
c0108fce:	01 d0                	add    %edx,%eax
c0108fd0:	01 c0                	add    %eax,%eax
c0108fd2:	01 d8                	add    %ebx,%eax
c0108fd4:	83 e8 30             	sub    $0x30,%eax
c0108fd7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0108fda:	8b 45 10             	mov    0x10(%ebp),%eax
c0108fdd:	0f b6 00             	movzbl (%eax),%eax
c0108fe0:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0108fe3:	83 fb 2f             	cmp    $0x2f,%ebx
c0108fe6:	7e 39                	jle    c0109021 <vprintfmt+0xe5>
c0108fe8:	83 fb 39             	cmp    $0x39,%ebx
c0108feb:	7f 34                	jg     c0109021 <vprintfmt+0xe5>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0108fed:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c0108ff1:	eb d3                	jmp    c0108fc6 <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0108ff3:	8b 45 14             	mov    0x14(%ebp),%eax
c0108ff6:	8d 50 04             	lea    0x4(%eax),%edx
c0108ff9:	89 55 14             	mov    %edx,0x14(%ebp)
c0108ffc:	8b 00                	mov    (%eax),%eax
c0108ffe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0109001:	eb 1f                	jmp    c0109022 <vprintfmt+0xe6>

        case '.':
            if (width < 0)
c0109003:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109007:	79 86                	jns    c0108f8f <vprintfmt+0x53>
                width = 0;
c0109009:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0109010:	e9 7a ff ff ff       	jmp    c0108f8f <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0109015:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010901c:	e9 6e ff ff ff       	jmp    c0108f8f <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
c0109021:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
c0109022:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109026:	0f 89 63 ff ff ff    	jns    c0108f8f <vprintfmt+0x53>
                width = precision, precision = -1;
c010902c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010902f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109032:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0109039:	e9 51 ff ff ff       	jmp    c0108f8f <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010903e:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c0109042:	e9 48 ff ff ff       	jmp    c0108f8f <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0109047:	8b 45 14             	mov    0x14(%ebp),%eax
c010904a:	8d 50 04             	lea    0x4(%eax),%edx
c010904d:	89 55 14             	mov    %edx,0x14(%ebp)
c0109050:	8b 00                	mov    (%eax),%eax
c0109052:	83 ec 08             	sub    $0x8,%esp
c0109055:	ff 75 0c             	pushl  0xc(%ebp)
c0109058:	50                   	push   %eax
c0109059:	8b 45 08             	mov    0x8(%ebp),%eax
c010905c:	ff d0                	call   *%eax
c010905e:	83 c4 10             	add    $0x10,%esp
            break;
c0109061:	e9 71 02 00 00       	jmp    c01092d7 <vprintfmt+0x39b>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0109066:	8b 45 14             	mov    0x14(%ebp),%eax
c0109069:	8d 50 04             	lea    0x4(%eax),%edx
c010906c:	89 55 14             	mov    %edx,0x14(%ebp)
c010906f:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0109071:	85 db                	test   %ebx,%ebx
c0109073:	79 02                	jns    c0109077 <vprintfmt+0x13b>
                err = -err;
c0109075:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0109077:	83 fb 06             	cmp    $0x6,%ebx
c010907a:	7f 0b                	jg     c0109087 <vprintfmt+0x14b>
c010907c:	8b 34 9d d4 b5 10 c0 	mov    -0x3fef4a2c(,%ebx,4),%esi
c0109083:	85 f6                	test   %esi,%esi
c0109085:	75 19                	jne    c01090a0 <vprintfmt+0x164>
                printfmt(putch, putdat, "error %d", err);
c0109087:	53                   	push   %ebx
c0109088:	68 01 b6 10 c0       	push   $0xc010b601
c010908d:	ff 75 0c             	pushl  0xc(%ebp)
c0109090:	ff 75 08             	pushl  0x8(%ebp)
c0109093:	e8 80 fe ff ff       	call   c0108f18 <printfmt>
c0109098:	83 c4 10             	add    $0x10,%esp
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010909b:	e9 37 02 00 00       	jmp    c01092d7 <vprintfmt+0x39b>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c01090a0:	56                   	push   %esi
c01090a1:	68 0a b6 10 c0       	push   $0xc010b60a
c01090a6:	ff 75 0c             	pushl  0xc(%ebp)
c01090a9:	ff 75 08             	pushl  0x8(%ebp)
c01090ac:	e8 67 fe ff ff       	call   c0108f18 <printfmt>
c01090b1:	83 c4 10             	add    $0x10,%esp
            }
            break;
c01090b4:	e9 1e 02 00 00       	jmp    c01092d7 <vprintfmt+0x39b>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c01090b9:	8b 45 14             	mov    0x14(%ebp),%eax
c01090bc:	8d 50 04             	lea    0x4(%eax),%edx
c01090bf:	89 55 14             	mov    %edx,0x14(%ebp)
c01090c2:	8b 30                	mov    (%eax),%esi
c01090c4:	85 f6                	test   %esi,%esi
c01090c6:	75 05                	jne    c01090cd <vprintfmt+0x191>
                p = "(null)";
c01090c8:	be 0d b6 10 c0       	mov    $0xc010b60d,%esi
            }
            if (width > 0 && padc != '-') {
c01090cd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01090d1:	7e 76                	jle    c0109149 <vprintfmt+0x20d>
c01090d3:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c01090d7:	74 70                	je     c0109149 <vprintfmt+0x20d>
                for (width -= strnlen(p, precision); width > 0; width --) {
c01090d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01090dc:	83 ec 08             	sub    $0x8,%esp
c01090df:	50                   	push   %eax
c01090e0:	56                   	push   %esi
c01090e1:	e8 17 f8 ff ff       	call   c01088fd <strnlen>
c01090e6:	83 c4 10             	add    $0x10,%esp
c01090e9:	89 c2                	mov    %eax,%edx
c01090eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01090ee:	29 d0                	sub    %edx,%eax
c01090f0:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01090f3:	eb 17                	jmp    c010910c <vprintfmt+0x1d0>
                    putch(padc, putdat);
c01090f5:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c01090f9:	83 ec 08             	sub    $0x8,%esp
c01090fc:	ff 75 0c             	pushl  0xc(%ebp)
c01090ff:	50                   	push   %eax
c0109100:	8b 45 08             	mov    0x8(%ebp),%eax
c0109103:	ff d0                	call   *%eax
c0109105:	83 c4 10             	add    $0x10,%esp
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c0109108:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010910c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109110:	7f e3                	jg     c01090f5 <vprintfmt+0x1b9>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0109112:	eb 35                	jmp    c0109149 <vprintfmt+0x20d>
                if (altflag && (ch < ' ' || ch > '~')) {
c0109114:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0109118:	74 1c                	je     c0109136 <vprintfmt+0x1fa>
c010911a:	83 fb 1f             	cmp    $0x1f,%ebx
c010911d:	7e 05                	jle    c0109124 <vprintfmt+0x1e8>
c010911f:	83 fb 7e             	cmp    $0x7e,%ebx
c0109122:	7e 12                	jle    c0109136 <vprintfmt+0x1fa>
                    putch('?', putdat);
c0109124:	83 ec 08             	sub    $0x8,%esp
c0109127:	ff 75 0c             	pushl  0xc(%ebp)
c010912a:	6a 3f                	push   $0x3f
c010912c:	8b 45 08             	mov    0x8(%ebp),%eax
c010912f:	ff d0                	call   *%eax
c0109131:	83 c4 10             	add    $0x10,%esp
c0109134:	eb 0f                	jmp    c0109145 <vprintfmt+0x209>
                }
                else {
                    putch(ch, putdat);
c0109136:	83 ec 08             	sub    $0x8,%esp
c0109139:	ff 75 0c             	pushl  0xc(%ebp)
c010913c:	53                   	push   %ebx
c010913d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109140:	ff d0                	call   *%eax
c0109142:	83 c4 10             	add    $0x10,%esp
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0109145:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0109149:	89 f0                	mov    %esi,%eax
c010914b:	8d 70 01             	lea    0x1(%eax),%esi
c010914e:	0f b6 00             	movzbl (%eax),%eax
c0109151:	0f be d8             	movsbl %al,%ebx
c0109154:	85 db                	test   %ebx,%ebx
c0109156:	74 26                	je     c010917e <vprintfmt+0x242>
c0109158:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010915c:	78 b6                	js     c0109114 <vprintfmt+0x1d8>
c010915e:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c0109162:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0109166:	79 ac                	jns    c0109114 <vprintfmt+0x1d8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0109168:	eb 14                	jmp    c010917e <vprintfmt+0x242>
                putch(' ', putdat);
c010916a:	83 ec 08             	sub    $0x8,%esp
c010916d:	ff 75 0c             	pushl  0xc(%ebp)
c0109170:	6a 20                	push   $0x20
c0109172:	8b 45 08             	mov    0x8(%ebp),%eax
c0109175:	ff d0                	call   *%eax
c0109177:	83 c4 10             	add    $0x10,%esp
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010917a:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010917e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109182:	7f e6                	jg     c010916a <vprintfmt+0x22e>
                putch(' ', putdat);
            }
            break;
c0109184:	e9 4e 01 00 00       	jmp    c01092d7 <vprintfmt+0x39b>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0109189:	83 ec 08             	sub    $0x8,%esp
c010918c:	ff 75 e0             	pushl  -0x20(%ebp)
c010918f:	8d 45 14             	lea    0x14(%ebp),%eax
c0109192:	50                   	push   %eax
c0109193:	e8 39 fd ff ff       	call   c0108ed1 <getint>
c0109198:	83 c4 10             	add    $0x10,%esp
c010919b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010919e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c01091a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01091a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01091a7:	85 d2                	test   %edx,%edx
c01091a9:	79 23                	jns    c01091ce <vprintfmt+0x292>
                putch('-', putdat);
c01091ab:	83 ec 08             	sub    $0x8,%esp
c01091ae:	ff 75 0c             	pushl  0xc(%ebp)
c01091b1:	6a 2d                	push   $0x2d
c01091b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01091b6:	ff d0                	call   *%eax
c01091b8:	83 c4 10             	add    $0x10,%esp
                num = -(long long)num;
c01091bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01091be:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01091c1:	f7 d8                	neg    %eax
c01091c3:	83 d2 00             	adc    $0x0,%edx
c01091c6:	f7 da                	neg    %edx
c01091c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01091cb:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c01091ce:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01091d5:	e9 9f 00 00 00       	jmp    c0109279 <vprintfmt+0x33d>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c01091da:	83 ec 08             	sub    $0x8,%esp
c01091dd:	ff 75 e0             	pushl  -0x20(%ebp)
c01091e0:	8d 45 14             	lea    0x14(%ebp),%eax
c01091e3:	50                   	push   %eax
c01091e4:	e8 99 fc ff ff       	call   c0108e82 <getuint>
c01091e9:	83 c4 10             	add    $0x10,%esp
c01091ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01091ef:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c01091f2:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01091f9:	eb 7e                	jmp    c0109279 <vprintfmt+0x33d>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c01091fb:	83 ec 08             	sub    $0x8,%esp
c01091fe:	ff 75 e0             	pushl  -0x20(%ebp)
c0109201:	8d 45 14             	lea    0x14(%ebp),%eax
c0109204:	50                   	push   %eax
c0109205:	e8 78 fc ff ff       	call   c0108e82 <getuint>
c010920a:	83 c4 10             	add    $0x10,%esp
c010920d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109210:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0109213:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010921a:	eb 5d                	jmp    c0109279 <vprintfmt+0x33d>

        // pointer
        case 'p':
            putch('0', putdat);
c010921c:	83 ec 08             	sub    $0x8,%esp
c010921f:	ff 75 0c             	pushl  0xc(%ebp)
c0109222:	6a 30                	push   $0x30
c0109224:	8b 45 08             	mov    0x8(%ebp),%eax
c0109227:	ff d0                	call   *%eax
c0109229:	83 c4 10             	add    $0x10,%esp
            putch('x', putdat);
c010922c:	83 ec 08             	sub    $0x8,%esp
c010922f:	ff 75 0c             	pushl  0xc(%ebp)
c0109232:	6a 78                	push   $0x78
c0109234:	8b 45 08             	mov    0x8(%ebp),%eax
c0109237:	ff d0                	call   *%eax
c0109239:	83 c4 10             	add    $0x10,%esp
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010923c:	8b 45 14             	mov    0x14(%ebp),%eax
c010923f:	8d 50 04             	lea    0x4(%eax),%edx
c0109242:	89 55 14             	mov    %edx,0x14(%ebp)
c0109245:	8b 00                	mov    (%eax),%eax
c0109247:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010924a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0109251:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0109258:	eb 1f                	jmp    c0109279 <vprintfmt+0x33d>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010925a:	83 ec 08             	sub    $0x8,%esp
c010925d:	ff 75 e0             	pushl  -0x20(%ebp)
c0109260:	8d 45 14             	lea    0x14(%ebp),%eax
c0109263:	50                   	push   %eax
c0109264:	e8 19 fc ff ff       	call   c0108e82 <getuint>
c0109269:	83 c4 10             	add    $0x10,%esp
c010926c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010926f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0109272:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0109279:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010927d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109280:	83 ec 04             	sub    $0x4,%esp
c0109283:	52                   	push   %edx
c0109284:	ff 75 e8             	pushl  -0x18(%ebp)
c0109287:	50                   	push   %eax
c0109288:	ff 75 f4             	pushl  -0xc(%ebp)
c010928b:	ff 75 f0             	pushl  -0x10(%ebp)
c010928e:	ff 75 0c             	pushl  0xc(%ebp)
c0109291:	ff 75 08             	pushl  0x8(%ebp)
c0109294:	e8 f8 fa ff ff       	call   c0108d91 <printnum>
c0109299:	83 c4 20             	add    $0x20,%esp
            break;
c010929c:	eb 39                	jmp    c01092d7 <vprintfmt+0x39b>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010929e:	83 ec 08             	sub    $0x8,%esp
c01092a1:	ff 75 0c             	pushl  0xc(%ebp)
c01092a4:	53                   	push   %ebx
c01092a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01092a8:	ff d0                	call   *%eax
c01092aa:	83 c4 10             	add    $0x10,%esp
            break;
c01092ad:	eb 28                	jmp    c01092d7 <vprintfmt+0x39b>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c01092af:	83 ec 08             	sub    $0x8,%esp
c01092b2:	ff 75 0c             	pushl  0xc(%ebp)
c01092b5:	6a 25                	push   $0x25
c01092b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01092ba:	ff d0                	call   *%eax
c01092bc:	83 c4 10             	add    $0x10,%esp
            for (fmt --; fmt[-1] != '%'; fmt --)
c01092bf:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01092c3:	eb 04                	jmp    c01092c9 <vprintfmt+0x38d>
c01092c5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01092c9:	8b 45 10             	mov    0x10(%ebp),%eax
c01092cc:	83 e8 01             	sub    $0x1,%eax
c01092cf:	0f b6 00             	movzbl (%eax),%eax
c01092d2:	3c 25                	cmp    $0x25,%al
c01092d4:	75 ef                	jne    c01092c5 <vprintfmt+0x389>
                /* do nothing */;
            break;
c01092d6:	90                   	nop
        }
    }
c01092d7:	e9 68 fc ff ff       	jmp    c0108f44 <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
c01092dc:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c01092dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
c01092e0:	5b                   	pop    %ebx
c01092e1:	5e                   	pop    %esi
c01092e2:	5d                   	pop    %ebp
c01092e3:	c3                   	ret    

c01092e4 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c01092e4:	55                   	push   %ebp
c01092e5:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c01092e7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01092ea:	8b 40 08             	mov    0x8(%eax),%eax
c01092ed:	8d 50 01             	lea    0x1(%eax),%edx
c01092f0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01092f3:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c01092f6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01092f9:	8b 10                	mov    (%eax),%edx
c01092fb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01092fe:	8b 40 04             	mov    0x4(%eax),%eax
c0109301:	39 c2                	cmp    %eax,%edx
c0109303:	73 12                	jae    c0109317 <sprintputch+0x33>
        *b->buf ++ = ch;
c0109305:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109308:	8b 00                	mov    (%eax),%eax
c010930a:	8d 48 01             	lea    0x1(%eax),%ecx
c010930d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109310:	89 0a                	mov    %ecx,(%edx)
c0109312:	8b 55 08             	mov    0x8(%ebp),%edx
c0109315:	88 10                	mov    %dl,(%eax)
    }
}
c0109317:	90                   	nop
c0109318:	5d                   	pop    %ebp
c0109319:	c3                   	ret    

c010931a <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010931a:	55                   	push   %ebp
c010931b:	89 e5                	mov    %esp,%ebp
c010931d:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0109320:	8d 45 14             	lea    0x14(%ebp),%eax
c0109323:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0109326:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109329:	50                   	push   %eax
c010932a:	ff 75 10             	pushl  0x10(%ebp)
c010932d:	ff 75 0c             	pushl  0xc(%ebp)
c0109330:	ff 75 08             	pushl  0x8(%ebp)
c0109333:	e8 0b 00 00 00       	call   c0109343 <vsnprintf>
c0109338:	83 c4 10             	add    $0x10,%esp
c010933b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010933e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0109341:	c9                   	leave  
c0109342:	c3                   	ret    

c0109343 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0109343:	55                   	push   %ebp
c0109344:	89 e5                	mov    %esp,%ebp
c0109346:	83 ec 18             	sub    $0x18,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0109349:	8b 45 08             	mov    0x8(%ebp),%eax
c010934c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010934f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109352:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109355:	8b 45 08             	mov    0x8(%ebp),%eax
c0109358:	01 d0                	add    %edx,%eax
c010935a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010935d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0109364:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109368:	74 0a                	je     c0109374 <vsnprintf+0x31>
c010936a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010936d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109370:	39 c2                	cmp    %eax,%edx
c0109372:	76 07                	jbe    c010937b <vsnprintf+0x38>
        return -E_INVAL;
c0109374:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0109379:	eb 20                	jmp    c010939b <vsnprintf+0x58>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010937b:	ff 75 14             	pushl  0x14(%ebp)
c010937e:	ff 75 10             	pushl  0x10(%ebp)
c0109381:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0109384:	50                   	push   %eax
c0109385:	68 e4 92 10 c0       	push   $0xc01092e4
c010938a:	e8 ad fb ff ff       	call   c0108f3c <vprintfmt>
c010938f:	83 c4 10             	add    $0x10,%esp
    // null terminate the buffer
    *b.buf = '\0';
c0109392:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109395:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0109398:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010939b:	c9                   	leave  
c010939c:	c3                   	ret    

c010939d <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c010939d:	55                   	push   %ebp
c010939e:	89 e5                	mov    %esp,%ebp
c01093a0:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c01093a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01093a6:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c01093ac:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c01093af:	b8 20 00 00 00       	mov    $0x20,%eax
c01093b4:	2b 45 0c             	sub    0xc(%ebp),%eax
c01093b7:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01093ba:	89 c1                	mov    %eax,%ecx
c01093bc:	d3 ea                	shr    %cl,%edx
c01093be:	89 d0                	mov    %edx,%eax
}
c01093c0:	c9                   	leave  
c01093c1:	c3                   	ret    

c01093c2 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c01093c2:	55                   	push   %ebp
c01093c3:	89 e5                	mov    %esp,%ebp
c01093c5:	57                   	push   %edi
c01093c6:	56                   	push   %esi
c01093c7:	53                   	push   %ebx
c01093c8:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c01093cb:	a1 80 4a 12 c0       	mov    0xc0124a80,%eax
c01093d0:	8b 15 84 4a 12 c0    	mov    0xc0124a84,%edx
c01093d6:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c01093dc:	6b f0 05             	imul   $0x5,%eax,%esi
c01093df:	01 fe                	add    %edi,%esi
c01093e1:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c01093e6:	f7 e7                	mul    %edi
c01093e8:	01 d6                	add    %edx,%esi
c01093ea:	89 f2                	mov    %esi,%edx
c01093ec:	83 c0 0b             	add    $0xb,%eax
c01093ef:	83 d2 00             	adc    $0x0,%edx
c01093f2:	89 c7                	mov    %eax,%edi
c01093f4:	83 e7 ff             	and    $0xffffffff,%edi
c01093f7:	89 f9                	mov    %edi,%ecx
c01093f9:	0f b7 da             	movzwl %dx,%ebx
c01093fc:	89 0d 80 4a 12 c0    	mov    %ecx,0xc0124a80
c0109402:	89 1d 84 4a 12 c0    	mov    %ebx,0xc0124a84
    unsigned long long result = (next >> 12);
c0109408:	a1 80 4a 12 c0       	mov    0xc0124a80,%eax
c010940d:	8b 15 84 4a 12 c0    	mov    0xc0124a84,%edx
c0109413:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0109417:	c1 ea 0c             	shr    $0xc,%edx
c010941a:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010941d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c0109420:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c0109427:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010942a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010942d:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0109430:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0109433:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109436:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109439:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010943d:	74 1c                	je     c010945b <rand+0x99>
c010943f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109442:	ba 00 00 00 00       	mov    $0x0,%edx
c0109447:	f7 75 dc             	divl   -0x24(%ebp)
c010944a:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010944d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109450:	ba 00 00 00 00       	mov    $0x0,%edx
c0109455:	f7 75 dc             	divl   -0x24(%ebp)
c0109458:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010945b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010945e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109461:	f7 75 dc             	divl   -0x24(%ebp)
c0109464:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0109467:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010946a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010946d:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109470:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109473:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0109476:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c0109479:	83 c4 24             	add    $0x24,%esp
c010947c:	5b                   	pop    %ebx
c010947d:	5e                   	pop    %esi
c010947e:	5f                   	pop    %edi
c010947f:	5d                   	pop    %ebp
c0109480:	c3                   	ret    

c0109481 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c0109481:	55                   	push   %ebp
c0109482:	89 e5                	mov    %esp,%ebp
    next = seed;
c0109484:	8b 45 08             	mov    0x8(%ebp),%eax
c0109487:	ba 00 00 00 00       	mov    $0x0,%edx
c010948c:	a3 80 4a 12 c0       	mov    %eax,0xc0124a80
c0109491:	89 15 84 4a 12 c0    	mov    %edx,0xc0124a84
}
c0109497:	90                   	nop
c0109498:	5d                   	pop    %ebp
c0109499:	c3                   	ret    
