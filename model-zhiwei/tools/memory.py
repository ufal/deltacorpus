from memory_profiler import profile

def my_func():
    a = [1] * (10 ** 6)
    b = [2] * (2 * 10 ** 7)
    del b
    return a

@profile
def f():
    for  i in range(100):
        my_func()
if __name__ == '__main__':
    f()
