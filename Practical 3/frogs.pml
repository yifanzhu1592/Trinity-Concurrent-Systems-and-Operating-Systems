byte positions[5]; 
byte frogs[5];
#define done (\
	((positions[0] == 2) || (positions[0] == 3) || (positions[0] == 4)) && \
	((positions[1] == 2) || (positions[1] == 3) || (positions[1] == 4)) && \
	((positions[2] == 2) || (positions[2] == 3) || (positions[2] == 4)) && \
	(positions[3] == 0) && \
	(positions[4] == 1) \
)

proctype jump() {
	int index;
	if 
	:: _pid == 1 ->
		index = _pid - 1;
		printf("START FROG %d AT %d GOING RIGHT\n", _pid, index + 1);
	:: else ->
		index = _pid;
		printf("START FROG %d AT %d GOING LEFT\n", _pid, index + 1);
	fi;
	
loop:

	atomic {
		if
		:: (_pid == 1) ->
			if 
			:: ((index + 1) < 5) -> 
				if 
				:: (positions[index + 1] == 0) ->
					printf("MOVE FROG%d FROM %d TO %d\n", _pid, index + 1, index + 2);
					positions[index + 1] = _pid;
					positions[index] = 0;
					frogs[_pid] = index + 2;
					frogs[0] = index + 1;
					index = index + 1;
					printf("EMPTY %d, FROG1@%d, FROG2@%d, FROG3@%d, FROG4@%d\n", frogs[0], frogs[1], frogs[2], frogs[3], frogs[4]);
				:: else -> skip;
				fi;
			:: ((index + 2) < 5) ->
				if 
				:: (positions[index + 2] == 0) ->
					printf("MOVE FROG%d FROM %d TO %d\n", _pid, index + 1, index + 3);
					positions[index + 2] = _pid;
					positions[index] = 0;
					frogs[_pid] = index + 3;
					frogs[0] = index + 1;
					index = index + 2;
					printf("EMPTY %d, FROG1@%d, FROG2@%d, FROG3@%d, FROG4@%d\n", frogs[0], frogs[1], frogs[2], frogs[3], frogs[4]);
				:: else -> skip;
				fi;
			:: else -> skip;
			fi;
		:: else -> 
			if 
			:: ((index - 1) > -1) -> 
				if 
				:: (positions[index - 1] == 0) ->
					printf("MOVE FROG%d FROM %d TO %d\n", _pid, index + 1, index);
					positions[index - 1] = _pid;
					positions[index] = 0;
					frogs[_pid] = index;
					frogs[0] = index + 1;
					index = index - 1;
					printf("EMPTY %d, FROG1@%d, FROG2@%d, FROG3@%d, FROG4@%d\n", frogs[0], frogs[1], frogs[2], frogs[3], frogs[4]);
				:: else -> skip;
				fi;
			:: ((index - 2) > -1) ->
				if 
				:: (positions[index - 2] == 0) ->
					printf("MOVE FROG%d FROM %d TO %d\n", _pid, index + 1, index - 1);
					positions[index - 2] = _pid;
					positions[index] = 0;
					frogs[_pid] = index - 1;
					frogs[0] = index + 1;
					index = index - 2;
					printf("EMPTY %d, FROG1@%d, FROG2@%d, FROG3@%d, FROG4@%d\n", frogs[0], frogs[1], frogs[2], frogs[3], frogs[4]);
				:: else -> skip;
				fi;
			:: else -> skip;
			fi;
		fi;
  }
  
	if
	:: (done) ->
	  printf( "DONE!\n" );
	  assert(false);
	:: else -> skip;
	fi;
	
	goto loop;
}

init {
	atomic {
		positions[0] = 1;
		positions[1] = 0;
		positions[2] = 2;
		positions[3] = 3;
		positions[4] = 4;
		frogs[0] = 2;
		frogs[1] = 1;
		frogs[2] = 3;
		frogs[3] = 4;
		frogs[4] = 5;
		run jump();
		run jump();
		run jump();
		run jump();
		printf("EMPTY %d, FROG1@%d, FROG2@%d, FROG3@%d, FROG4@%d\n", frogs[0], frogs[1], frogs[2], frogs[3], frogs[4]);
	}
}
