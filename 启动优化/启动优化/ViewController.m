//
//  ViewController.m
//  启动优化
//
//  Created by Simon on 2021/3/15.
//

/**
 
 */
#import "ViewController.h"
#import "dlfcn.h"
#import <libkern/OSAtomic.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

void __sanitizer_cov_trace_pc_guard_init(uint32_t *start, uint32_t *stop) {
     static uint64_t N;  // Counter for the guards.
     if (start == stop || *start) return;  // Initialize only once.
     printf("INIT: %p %p\n", start, stop);
     for (uint32_t *x = start; x < stop; x++)
       *x = ++N;  // Guards should start from 1.
}


//初始化原子队列
static OSQueueHead list = OS_ATOMIC_QUEUE_INIT;
//定义节点结构体
typedef struct {
    void *pc;   //存下获取到的PC
    void *next; //指向下一个节点
} Node;


void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
     void *PC = __builtin_return_address(0);
     Node *node = malloc(sizeof(Node));
     *node = (Node){PC, NULL};
     // offsetof() 计算出列尾，OSAtomicEnqueue() 把 node 加入 list 尾巴
     OSAtomicEnqueue(&list, node, offsetof(Node, next));
}

///二进制重排后链接库路径
- (void)printLibLinkPath {
    NSMutableArray *arr = [NSMutableArray array];
    while(1){
        //有进就有出，这个方法和 OSAtomicEnqueue() 类比使用
        Node *node = OSAtomicDequeue(&list, offsetof(Node, next));
        //退出机制
        if (node == NULL) {
            break;
        }
        //获取函数信息
        Dl_info info;
        dladdr(node->pc, &info);
        NSString *sname = [NSString stringWithCString:info.dli_sname encoding:NSUTF8StringEncoding];
        printf("%s \n", info.dli_sname);
        //处理c函数及block前缀
        BOOL isObjc = [sname hasPrefix:@"+["] || [sname hasPrefix:@"-["];
        //c函数及block需要在开头添加下划线
        sname = isObjc ? sname: [@"_" stringByAppendingString:sname];
        
        //去重
        if (![arr containsObject:sname]) {
            //因为入栈的时候是从上至下，取出的时候方向是从下至上，那么就需要倒序，直接插在数组头部即可
            [arr insertObject:sname atIndex:0];
        }
    }
      
    //去掉 touchesBegan 方法 启动的时候不会用到这个
    [arr removeObject:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    //数组合成字符串
    NSString * funcStr = [arr  componentsJoinedByString:@"\n"];
    //写入文件
    NSString * filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"link.order"];
    NSData * fileContents = [funcStr dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", filePath);
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:fileContents attributes:nil];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self printLibLinkPath];
}

@end
