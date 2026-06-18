# https://proproprogs.ru/ga/ga-delaem-geneticheskiy-algoritm-dlya-zadachi-onemax

from sqlite3 import connect
from os import path
from random import seed, random, randint
from sys import argv

# from os import getcwd
# cwd_os = getcwd()
# print(f"working dir: {cwd_os}")

type_id = int(argv[1])


POPULATION_SIZE = 200
P_CROSSOVER = 0.9
P_MUTATION = 0.1
RANDOM_SEED = 42
seed(RANDOM_SEED)

db_path = 'data/train.db'
if not path.exists(db_path):
	raise Exception("db not exists")

with connect(db_path, isolation_level=None) as conn:
	cursor = conn.cursor()

	cursor.execute(f'''
		select s.id, s.fitness, w.joint, w.range
		from (
			select s.id, s.fitness
			from session s
			where s.type_id = {type_id}
			 and s.fitness > 0
			order by s.fitness desc --s.ctime desc, s.id
			limit {POPULATION_SIZE}
		) s
		join walk_param w on s.id = w.session_id		
	''')
	conn.commit()

	sessions = []
	session_id = -1
	for id, fitness, joint, range_ in cursor.fetchall():
		if session_id != id:
			session = { "id": id, "fitness": fitness, "params": { joint: range_ } }
			session_id = id
			sessions.append(session)
		else:
			session["params"][joint] = range_

	pop_size = len(sessions)
	if pop_size % 2 > 0:
		sessions.pop()
		pop_size -= 1
	# print(sessions)

	max_pop_id = pop_size - 1
	# print(max_pop_id)

	param_keys = list(sessions[0]["params"].keys())
	# print(param_keys)

	max_params = len(param_keys) - 1
	# print(max_params)
	
	max_fitness = max(map(lambda x: x["fitness"], sessions))
	# print(max_fitness)


	# selection
	offspring = []
	for _ in range(pop_size):
		i1 = i2 = i3 = 0
		while i1 == i2 or i1 == i3 or i2 == i3:
			i1, i2, i3 = randint(0, max_pop_id), randint(0, max_pop_id), randint(0, max_pop_id)
		offspring.append(max([sessions[i1], sessions[i2], sessions[i3]], key=lambda ind: ind["fitness"]))
	# print(offspring)


	# crossover
	for i in range(0, pop_size, 2):
		if random() < P_CROSSOVER:
			child1 = offspring[i]
			child2 = offspring[i + 1]
			# print(i)
			# print(child1, child2)
			joint = param_keys[randint(0, max_params)]
			child1["params"][joint], child2["params"][joint] = child2["params"][joint], child1["params"][joint]
			# print(child1, child2)


	# mutation
	for mutant in offspring:
		if random() < P_MUTATION:
			joint = param_keys[randint(0, max_params)]
			mutant["params"][joint] = random()


	# save to DB
	for session in offspring:
		cursor.execute(f"INSERT INTO session (type_id) VALUES ({type_id})")
		session_id = cursor.lastrowid
		conn.commit()
		for joint, range_ in dict(session["params"]).items():
			cursor.execute("INSERT INTO walk_param (session_id, joint, range) VALUES (?, ?, ?)", (session_id, joint, range_))
			conn.commit()



