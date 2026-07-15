#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include <errno.h>
#include <sys/stat.h>

#include "alu_model.h"
#include "gen_vectors_parallel.h"

// Number of generation threads.
#define N_THREADS 4

// Each thread receives a range of A values to process.
typedef struct
{
    uint8_t a_start;
    uint8_t a_end; // inclusive
    vector_block_t result;
} thread_arg_t;

// Function executed by each thread.
// Generates all (A, B, OP) combinations for its range of A.
static void *generate_block(void *arg)
{
    thread_arg_t *targ = (thread_arg_t *)arg;

    // Compute how many entries will be generated.
    // For each A: 256 values of B x 8 operations.
    size_t range = (size_t)(targ->a_end - targ->a_start + 1);
    size_t total = range * 256 * 8;

    targ->result.entries = malloc(total * sizeof(vector_entry_t));
    if (targ->result.entries == NULL)
    {
        perror("malloc");
        targ->result.count = 0;
        return NULL;
    }

    size_t idx = 0;

    for (uint16_t a = targ->a_start; a <= targ->a_end; a++)
    {
        for (uint16_t b = 0; b < 256; b++)
        {
            for (uint8_t op = 0; op < 8; op++)
            {
                alu_result_t r = alu_execute((uint8_t)a, (uint8_t)b, (alu_op_t)op);

                targ->result.entries[idx].a = (uint8_t)a;
                targ->result.entries[idx].b = (uint8_t)b;
                targ->result.entries[idx].op = op;
                targ->result.entries[idx].expected_result = r.result;
                targ->result.entries[idx].zero = r.zero;
                targ->result.entries[idx].carry = r.carry;
                targ->result.entries[idx].negative = r.negative;
                targ->result.entries[idx].overflow = r.overflow;

                idx++;
            }
        }
    }

    targ->result.count = idx;
    return NULL;
}

int main(void)
{
    pthread_t threads[N_THREADS];
    thread_arg_t args[N_THREADS];

    // Split the 256 values of A evenly among the threads.
    // With N_THREADS = 4: thread 0 processes A from 0..63, thread 1 from 64..127, etc.
    uint16_t step = 256 / N_THREADS;

    for (int i = 0; i < N_THREADS; i++)
    {
        args[i].a_start = (uint8_t)(i * step);
        args[i].a_end = (uint8_t)(i * step + step - 1);
        args[i].result.entries = NULL;
        args[i].result.count = 0;

        if (pthread_create(&threads[i], NULL, generate_block, &args[i]) != 0)
        {
            perror("pthread_create");
            return 1;
        }
    }

    // Wait for all threads to finish.
    for (int i = 0; i < N_THREADS; i++)
    {
        pthread_join(threads[i], NULL);
    }

    // Create the output directory if it does not already exist.
    if (mkdir("build", 0755) != 0 && errno != EEXIST)
    {
        perror("mkdir");
        return 1;
    }

    // Open the output file and write all blocks in order.
    FILE *f = fopen("build/alu_vectors.txt", "w");
    if (f == NULL)
    {
        perror("fopen");
        return 1;
    }

    size_t total_written = 0;

    for (int i = 0; i < N_THREADS; i++)
    {
        vector_block_t *blk = &args[i].result;

        for (size_t j = 0; j < blk->count; j++)
        {
            vector_entry_t *e = &blk->entries[j];
            fprintf(
                f,
                "%02X %02X %X %02X %u %u %u %u\n",
                e->a,
                e->b,
                e->op,
                e->expected_result,
                e->zero,
                e->carry,
                e->negative,
                e->overflow);
            total_written++;
        }

        free(blk->entries);
    }

    fclose(f);
    printf("Vectors generated: %zu lines in build/alu_vectors.txt\n", total_written);
    return 0;
}
