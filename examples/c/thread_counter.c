#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

#define N_THREADS 4
#define N_INC 100000

static int counter = 0;
static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

void *worker(void *arg)
{
    int id = *(int *)arg;

    for (int i = 0; i < N_INC; i++)
    {
        // Critical section: only one thread may enter at a time.
        pthread_mutex_lock(&mutex);
        counter++;
        pthread_mutex_unlock(&mutex);
    }

    printf("Thread %d finished.\n", id);
    return NULL;
}

int main(void)
{
    pthread_t threads[N_THREADS];
    int ids[N_THREADS];

    for (int i = 0; i < N_THREADS; i++)
    {
        ids[i] = i;
        if (pthread_create(&threads[i], NULL, worker, &ids[i]) != 0)
        {
            perror("pthread_create");
            return 1;
        }
    }

    for (int i = 0; i < N_THREADS; i++)
    {
        pthread_join(threads[i], NULL);
    }

    printf("counter = %d\n", counter);
    printf("expected = %d\n", N_THREADS * N_INC);

    pthread_mutex_destroy(&mutex);
    return 0;
}
