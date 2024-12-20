#define _CRT_SECURE_NO_DEPRECATE

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

typedef char i8;
typedef unsigned char u8;
typedef int i16;
typedef unsigned int u16;
typedef long i32;
typedef unsigned long u32;
typedef long long i64;
typedef unsigned long long u64;

char EMPTY = '.';
char BLOCK = 'X';

char *readDisk(const char *path, u64 *disk_len, i64* ids, u64* ids_len)
{
    FILE *file = fopen(path, "r");
    if (file == NULL)
    {
        perror("Failed to read blocks");
        return NULL;
    }

    char *disk = malloc(sizeof(char) * 1024 * 1024 * 10);
    char buffer[3];
    u64 id = 0;
    u64 disk_index = 0;

    while (1)
    {
        buffer[0] = fgetc(file);
        buffer[1] = fgetc(file);

        if (buffer[0] == EOF && buffer[1] == EOF)
        {
            break;
        }

        u64 size_of_file_block = buffer[0] - '0';
        u64 size_of_free_block = 0;
        if (buffer[1] != EOF)
        {
            size_of_free_block = buffer[1] - '0';
        }

        while (size_of_file_block > 0)
        {
						ids[disk_index] = id;
						(*ids_len)++;
            disk[disk_index] = BLOCK;
            disk_index++;
            (*disk_len)++;
            size_of_file_block--;
        }

        while (size_of_free_block > 0)
        {
						ids[disk_index] = 0;
						(*ids_len)++;
            disk[disk_index] = EMPTY;
            disk_index++;
            (*disk_len)++;
            size_of_free_block--;
        }

        id++;
    }

    fclose(file);
    return disk;
}

void printDisk(char* disk, u64 disk_len) {
    for (size_t i = 0; i < disk_len; i++)
    {
        printf("%c", disk[i]);
    }
}

u64 getChecksum(char* disk, u64 disk_len, i64* ids, u64 ids_len) {
	printf("Checksum\n");
	u64 checksum = 0;
	for (u64 i = 0; i < disk_len; i++) {
		if(disk[i] == EMPTY) {
			return checksum;
		}
		i64 id = ids[i];
		checksum += i * id;
	}
	return checksum;
}

//NOTE: unsafe
void until(char* buffer, char c, u64 len, u64* index) {
	while(buffer[*index] != c) {
		if(*index > len) {
			break;
		}

		(*index)++;
	}
} 

int main()
{
    u64 disk_len = 0;
		u64 ids_len = 0;
		i64* ids = malloc(sizeof(i64) * 1024 * 1024);
    char *disk = readDisk("./day9.txt", &disk_len, ids, &ids_len);
		printf("Disk loaded\n");
    if (disk == NULL)
    {
        return -1;
    }

		u64 free_blocks_index = 0;
		until(disk, EMPTY, disk_len, &free_blocks_index);

		printf("Moving\n");
    for (i64 disk_index = disk_len-1; disk_index > -1; disk_index--)
    {
			if(disk[disk_index] == EMPTY) continue;

			if(free_blocks_index > disk_len-1) {
				printf("Run out of disk space!\n");
				break;
			}

			u64 tmp = ids[disk_index];
			ids[disk_index] = ids[free_blocks_index];
			ids[free_blocks_index] = tmp;

			disk[free_blocks_index] = disk[disk_index];
			disk[disk_index] = EMPTY;
			until(disk, EMPTY, disk_len, &free_blocks_index);

			//printf("%lu %lu\n", disk_index, free_blocks_index);
			if(disk_index == free_blocks_index) break;
    }

		u64 check = getChecksum(disk, disk_len, ids, ids_len);

    printf("checksum: %llu", check);

    return 0;
}
