# BeefyBoids
Boids in beeflang. Going to be a environment simulation with boids. Boids will eat food, reproduce, get hunted by predators, and die of old age. It's mostly a project for my university AI assignment 

# Simulation info
Uses a spatial hash to improve performance. Boids only care about boids in their spatial hash cell + it's neighbors. 

There's also a "flock" system where boids will be assigned to flocks and will only cohese and align with boids in their own flock (assuming they're in the same or adjacent cells)


# TODO

- [ ] Multithreading (this is a BIG maybe. Performance is already fine with >1000 boids, but multithreading would mean way more would be possible)

- [ ] Family trees (you'll be able to see the family tree of boids and how long a family has been alive as-well as extinct families of boids)

- [x] Predators (boids that hunt other boids. Boids will run away from predators)

- [ ] Food 
 
- [ ] Reproduction

- [ ] Death

- [ ] Aging (boids become bigger with age)

- [x] Stats (boids have random stats such as random max speed, random max acceleration, etc. This is to hopefully make it so boids with better stats survive and reproduce while boids with worse stats die off)


