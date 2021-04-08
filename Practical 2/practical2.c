#include <stdbool.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include "cond.c"

typedef struct {
    bool occupied;
    pthread_mutex_t mutex;
    pthread_cond_t more;
    pthread_cond_t less;
} buffer_t;



int pnum;  // number updated when producer runs.
int csum;  // sum computed using pnum when consumer runs.

int (*pred)(int); // predicate indicating if pnum is to be consumed

int produceT() {
  scanf("%d",&pnum); // read a number from stdin
  return pnum;
}

void *Produce(void *a) {
	buffer_t *b = (buffer_t *)a;
  int p;

  p=1;
  while (p) {
    pthread_mutex_lock(&b->mutex);
   
    while (b->occupied == true)
        pthread_cond_wait(&b->less, &b->mutex);

    assert(b->occupied == false);
    
    printf("@P-READY\n");
    p = produceT();
    printf("@PRODUCED %d\n",p);

    b->occupied = true;

    pthread_cond_signal(&b->more);

    pthread_mutex_unlock(&b->mutex);
  }
  printf("@P-EXIT\n");
  pthread_exit(NULL);
}


int consumeT(int pnum) {
  if ( pred(pnum) ) { csum += pnum; }
  return pnum;
}

void *Consume(void *a) {
	buffer_t *b = (buffer_t *)a;
  int p;

  p=1;
  while (p) {
    pthread_mutex_lock(&b->mutex);
    
    while(b->occupied == false)
        pthread_cond_wait(&b->more, &b->mutex);

    assert(b->occupied == true);
    
    printf("@C-READY\n");
    p = consumeT(pnum);
    printf("@CONSUMED %d\n",csum);
    
    b->occupied = false;
    
    pthread_cond_signal(&b->less);
    
    pthread_mutex_unlock(&b->mutex);
  }
  printf("@C-EXIT\n");
  pthread_exit(NULL);
}


int main (int argc, const char * argv[]) {
  // the current number predicate
  static pthread_t prod,cons;
	long rc;
	buffer_t buffer = {};

  pred = &cond1;
  if (argc>1) {
    if      (!strncmp(argv[1],"2",10)) { pred = &cond2; }
    else if (!strncmp(argv[1],"3",10)) { pred = &cond3; }
  }

  pnum = 999;
  csum=0;
  srand(time(0));

  printf("@P-CREATE\n");
 	rc = pthread_create(&prod,NULL,Produce,&buffer);
	if (rc) {
			printf("@P-ERROR %ld\n",rc);
			exit(-1);
		}
  printf("@C-CREATE\n");
 	rc = pthread_create(&cons,NULL,Consume,&buffer);
	if (rc) {
			printf("@C-ERROR %ld\n",rc);
			exit(-1);
		}

  printf("@P-JOIN\n");
  pthread_join( prod, NULL);
  printf("@C-JOIN\n");
  pthread_join( cons, NULL);


  printf("@CSUM=%d.\n",csum);

  return 0;
}
