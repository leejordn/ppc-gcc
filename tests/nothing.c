int main()
{
    static volatile int my_int = 0; // Ensure this doesn't get optimized away
    while (1)
    {
        ++my_int;
        if (my_int == 500)
            break;
    }
    return 0;
}
