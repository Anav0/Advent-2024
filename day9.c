#define _CRT_SECURE_NO_DEPRECATE

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

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

typedef struct {
  char taken;
  u64 id;
  u32 len;

  struct Block *prev;
  struct Block *next;
} Block;

u64 readSize(char v) {
    u64 size = 0;
    if (v >= '0' && v <= '9') {
      size = v - '0';
    }
		return size;
}

void insertBlock(u64 id, u64 size, u64 taken, Block* blocks, u64* blocks_len) {
      Block block = {
          .id = id,
          .taken = taken,
          .len = size,
          .prev = NULL,
          .next = NULL,
      };
      blocks[*blocks_len] = block;
      (*blocks_len)++;
      Block *curr = &blocks[*blocks_len - 1];
      if (*blocks_len > 1) {
        Block *prev = &blocks[*blocks_len - 2];
        prev->next = curr;
        curr->prev = prev;
      }
}

void readBlocks(const char *path, Block *blocks, u64 *blocks_len) {
  FILE *file = fopen(path, "r");
  if (file == NULL) {
    perror("Failed to read blocks");
    return;
  }

  char buffer[3];
  u64 id = 0;
  (*blocks_len) = 0;

  while (1) {
    buffer[0] = fgetc(file);
    buffer[1] = fgetc(file);

    if (buffer[0] == EOF && buffer[1] == EOF) {
      break;
    }

    u64 size_of_file_block = readSize(buffer[0]);
    u64 size_of_free_block = readSize(buffer[1]);

    if (size_of_file_block > 0) {
			insertBlock(id, size_of_file_block, 1, blocks, blocks_len);
      id++;
    }

    if (size_of_free_block > 0) {
			insertBlock(0, size_of_free_block, 0, blocks, blocks_len);
    }
  }

  fclose(file);
}

void printDisk(char *disk, u64 disk_len) {
  for (size_t i = 0; i < disk_len; i++) {
    printf("%c", disk[i]);
  }
}

u64 getChecksum(Block *block) {
  while (block->prev != NULL) {
    block = block->prev;
  }
  u64 checksum = 0;
  u64 index = 0;
  while (block != NULL) {
    for (u32 i = 0; i < block->len; i++) {
      checksum += index * block->id;
      index++;
    }
    block = block->next;
  }
  return checksum;
}

// TODO: checksum
// NOTE: unsafe
Block *getLeftmostFreeBlock(Block *buffer, Block *block) {
  while (buffer->prev != NULL) {
    buffer = buffer->prev;
  }
  while (buffer != NULL) {
    if (buffer->taken != 0 || buffer->len < block->len) {
			if (buffer->id == block->id) {
				 return NULL;
			}
      buffer = buffer->next;
      continue;
    }
    return buffer;
  }
  return NULL;
}

void printPointers(Block *b) {
  while (b->prev != NULL) {
    b = b->prev;
  }

  while (b != NULL) {
    printf("(%p) %lu | %llu prev: %p, next: %p, len: %lu\n", b, b->taken, b->id, b->prev, b->next, b->len);
    b = b->next;
  }
}

void printBlocks(Block *b) {
  while (b->prev != NULL) {
    b = b->prev;
  }

  while (b != NULL) {
    for (u32 j = 0; j < b->len; j++) {
      if (b->taken == 0) {
        printf(".");
      } else {
        printf("%llu", b->id);
      }
    }
    b = b->next;
  }
}

int main() {
  Block *blocks = malloc(sizeof(Block) * 64000);
  u64 blocks_len = 0;
  readBlocks("./day9.txt", blocks, &blocks_len);
  printf("Number of blocks: %llu\n", blocks_len);

  Block *block = &blocks[blocks_len - 1];
	Block* first_block_checked = block;
	u64 first_block_id = block->id;
	u64 counter = 0;
  while (1) {
		if(block->prev == NULL || (counter > 0 && block->id == first_block_id && block->taken == 1)) {
			break;
		}

    if (block->taken == 0) {
      block = block->prev;
      continue;
    }

    Block *free_block = getLeftmostFreeBlock(blocks, block);

    if (free_block == NULL) {
      block = block->prev;
      continue;
    }

    u32 len_diff = free_block->len - block->len;

		Block* next_to_repos = block->prev;
		//1. Replace moved block with free space
		Block* block_prev = block->prev;
		Block* block_next = block->next;

		//2. If free block is of the same size, remove it completly
		Block* free_prev = free_block->prev;
		Block* free_next = free_block->next;

		if(free_block->len-block->len == 0) {
			free_block->id = block->id;
			free_block->taken = block->taken;
			block->id = 0;
			block->taken = 0;
		} else {
			//1. Insert new block before free_block
			Block replacment = {
				.len = block->len,
				.id = block->id,
				.taken = 1,
				.prev = free_block->prev,
				.next = free_block,
			};
			blocks[blocks_len] = replacment;
			Block* replacment_ptr = &blocks[blocks_len];
			blocks_len++;

			if(free_prev!=NULL) {
				free_prev->next = replacment_ptr;
			}
			free_block->prev = replacment_ptr;

			//2. Change block to free block
			block->id = 0;
			block->taken = 0;

			//3. Change size of free_block and update it's prev ptr
			free_block->len -= block->len;
		}

		block = next_to_repos;
		counter++;
  }

  printf("\n");

  u64 check = getChecksum(first_block_checked);

  printf("checksum: %llu", check);

  return 0;
}
