using Boids.lib;
using System;
using System.Linq;

using System.Collections;

using raylib_beef.Types;
using System.Diagnostics;
using static raylib_beef.Raylib;
using static raylib_beef.Raymath;
using static raylib_beef.rlgl;
namespace Boids
{
	struct Stats
	{
		public float maxSpeed { get; set mut; }
		public float maxForce { get; set mut; }
		public float health { get; set mut; }
		public float age { get; set mut; }
		public float maxAge { get; set mut; }
		public float matingAge { get; set mut; }
		public float generation { get; set mut; }

		public List<Stats> previousGenerationStats { get; set mut; };


		/*
			Hunger was never implemented due to annoying bugs that were nearly impossible to diagnose such as:

			Food not being removed properly from hashmap
			Boids getting stuck at seemingly arbitrary positions when trying to go to food while trying to eat
			Predators being able to kill a lot of boids by going near food source where boids are eating (it will
		basically get sucked in)

		*/

		public float hunger { get; set mut; }
		//How much a boid needs to be hungry before needing to eat
		public float hungerTolerance { get; set mut; }


		//Constructor for when boids are first created
		public this(bool isPred)
		{
			int modifier = isPred ? 2 : 1 + (rand.Next(1, 30) / 100);
			maxSpeed = float((rand.Next(3, 10)) * modifier)/ (!isPred ? 8 : 5);
			maxForce = Math.Abs((float(rand.Next(1, 3)) / 100) * modifier);
			health = 100;
			hungerTolerance = rand.Next(30, 70);
			age = 0;
			matingAge = rand.Next(50, 150);
			maxAge = rand.Next(240, 300);
			hunger = 0;
			generation = 0;
			previousGenerationStats = new .();
			previousGenerationStats.Add(this);
		}

		//Constructor for boids that are children of other boids.
		public this(Boid parent1, Boid parent2)
		{
			//Create new stats using parent1 and parent2 stats as a 'base'

			float minSpeedStat = Math.Min(parent1.boidStats.maxSpeed, parent2.boidStats.maxSpeed);
			float maxSpeedStat = Math.Max(parent1.boidStats.maxSpeed, parent2.boidStats.maxSpeed);

			float minForceStat = Math.Min(parent1.boidStats.maxForce, parent2.boidStats.maxForce);
			float maxForceStat = Math.Max(parent1.boidStats.maxForce, parent2.boidStats.maxForce);

			float minMatingAgeStat = Math.Min(parent1.boidStats.matingAge, parent2.boidStats.matingAge);
			float maxMatingAgeStat = Math.Max(parent1.boidStats.matingAge, parent2.boidStats.matingAge);

			float minAgeStat = Math.Min(parent1.boidStats.maxAge, parent2.boidStats.maxAge);
			float maxAgeStat = Math.Max(parent1.boidStats.maxAge, parent2.boidStats.maxAge);


			maxSpeed = Math.Abs((float)(rand.NextDouble() * (maxSpeedStat - minSpeedStat) + minSpeedStat));
			maxForce = Math.Abs((float)(rand.NextDouble() * (maxForceStat - minForceStat) + minForceStat));
			matingAge = Math.Abs((float)(rand.NextDouble() * (maxMatingAgeStat - minMatingAgeStat) + minMatingAgeStat));
			maxAge = Math.Abs((float)(rand.NextDouble() * (maxAgeStat - minAgeStat) + minAgeStat));


			health = 100;
			hungerTolerance = rand.Next(30, 70);
			age = 0;
			hunger = 0;
			generation = parent1.boidStats.generation + 1;

			previousGenerationStats = new .();
			previousGenerationStats.AddRange(parent1.boidStats.previousGenerationStats);
			previousGenerationStats.Add(this);
		}
	}


	class Boid : Entity
	{
		Vector2 head;
		Vector2 tailL;
		Vector2 mid;
		Vector2 tailR;

		public bool deadFlag { get; private set; }

		public Flock flock;

		public Vector2 acceleration;
		public Vector2 prevPosition;
		public Vector2 velocity;

		public bool isPredator = false;
		public Boid currentMate = null;

		public bool hasReproduced = false;

		public Color color = Color.BLACK;
		public Stats boidStats;

		List<Entity> boids;

		public float heading;

		public Statemachine boidStates;

		public Vector2 matingSpot;

		public Stopwatch matingTimer ~ delete _;


		public this(float x, float y, float s, float r, bool predator = false)
		{
			boids = new List<Entity>();
			isPredator = predator;
			position.x = x;
			position.y = y;
			Scale = s;
			Rotation = r;
			boidStats = Stats(predator);
			aabb = .(0, 0, 30, 30);

			acceleration = Vector2Normalize(randVector(10));
			heading = Math.Atan2(acceleration.y, acceleration.x) - (90 * DEG2RAD);
			Rotation = heading;
			boidStates = new Statemachine();


			onLeftClick.Add(new () => { BoidClicked(); });
			onRightClick.Add(new () => { BoidClicked2(); });
			matingTimer = new .();
			State wanderState = State(this, => Wander, "WanderState");
			State mateState = State(this, => Reproduce, "Mate");
			boidStates.Add(wanderState);
			boidStates.Add(mateState);
		}

		public float CalculateFitness()
		{
			return (boidStats.maxSpeed + boidStats.maxForce + (250 * (250 / boidStats.matingAge)) + (boidStats.maxAge * (boidStats.maxAge / boidStats.maxAge))) / 4;
		}

		public ~this()
		{
			//delete boids;
		}

		public Vector2 limitVec(Vector2 vector, float maxMagnitude)
		{
			Vector2 v = vector;
		    if (Vector2LengthSqr(vector) > (maxMagnitude * maxMagnitude))
		    {
		        v = Vector2Normalize(vector)*maxMagnitude;
		    }
			return v;
		}

		public float Vector2LengthSqr(Vector2 v){
			return (v.x*v.x) + (v.y*v.y);
		}

		public static void Wander(ref Entity e)
		{
			Boid b = (Boid)e;

			b.ApplyForce(b.separate()*1.25f);
			b.ApplyForce(b.align());
			b.ApplyForce(b.cohese());

			if (!b.isPredator)
				b.ApplyForce(b.flee() * 20f);

			if (b.currentMate == null && !b.hasReproduced && b.boidStats.age > b.boidStats.matingAge)
			{
				for (int i = 0; i < b.flock.boids.Count; i++)
				{
					if (b.currentMate != null)
						break;
					Boid other = b.flock.boids[i];


					if (other != b && other.boidStats.age > other.boidStats.matingAge && other.currentMate == null && !other.hasReproduced)
					{
						//Calculate relativeFitness of the two boids.
						float relativeFitness = b.CalculateFitness() - other.CalculateFitness();
						if ((relativeFitness <= -10))
						{//Determine if mate is suitable (is fitter by a certain amount)
							other.currentMate = b;
							b.currentMate = other;
							b.matingSpot = .(rand.Next(100, worldWidth - 100), rand.Next(100, worldHeight - 100));
							other.matingSpot = b.matingSpot;

							b.boidStates.SwitchState("Mate");
							other.boidStates.SwitchState("Mate");

							break;
						}
					}
				}
			}
		}



		public static void Reproduce(ref Entity e)
		{
			Boid b = (Boid)e;

			b.ApplyForce(b.separate() * 2.5f);

			if (b.currentMate != null && !b.hasReproduced)
			{
				b.ApplyForce(b.reproduce(b.matingSpot) * 20);
				float dist = Vector2Distance(b.position, b.currentMate.position);
				if (dist < 5 && !b.matingTimer.IsRunning)
				{
					b.matingTimer.Start();
				}
				else if (dist > 5 && b.matingTimer.IsRunning)
				{
					b.matingTimer.Reset();
				}
				if (b.matingTimer.IsRunning)
				{
					//Add a bit of randomness to the amount of mating time for the boids. If this aligns (which it'll
					// rarely do) with the mates mating timer, it will create two children (basically twins)
					if (b.matingTimer.Elapsed.TotalSeconds > rand.Next(3, 8) || b.hasReproduced)
					{
						b.matingTimer.Reset();
						b.currentMate.matingTimer.Reset();
						//our mate can become null during the timer wait.
						if (b.currentMate != null || !b.hasReproduced)
						{
						//Do reproduce
							Boid child = new .(b.position.x, b.position.y, 1, 0, b.isPredator);
							child.boidStats = .(b, b.currentMate);
							child.flock = b.flock;
							child.color = b.flock.generateRandomColor(b.flock.flockMixColor);

							b.flock.boids.Add(child);
							hash.Add(child);
						}
						b.hasReproduced = true;
						b.currentMate.hasReproduced = true;
						b.boidStates.SwitchState("WanderState");
						b.currentMate.boidStates.SwitchState("WanderState");
						b.currentMate.currentMate = default;
						b.currentMate = default;
					}
				}
			}
			if (!b.isPredator)
			{
				b.ApplyForce(b.flee());
			}
		}

		public override void Draw()
		{
			float* X = &position.x;
			float* Y = &position.y;
			base.Draw();

			float cos = Math.Cos(Rotation);
			float sin = Math.Sin(Rotation);
			heading = Math.Atan2(velocity.y, velocity.x) - (90 * DEG2RAD);
			Rotation = heading;

			aabb = .((float) * X - 10, (float) * Y - 10, 20, 20);

			head = .(*X, *Y + (20 * Scale));
			tailL = .(*X - (5 * Scale), *Y + (5 * Scale));
			mid = .(*X, *Y + (10 * Scale));
			tailR = .(*X + (5 * Scale), *Y + (5 * Scale));

			Vector2[?] points = .(
				head, tailR, mid, tailL, head
				);

			//Rotate
			for (int i = 0; i < points.Count; i++)
			{
				Vector2 oldPos = points[i];
				points[i].x = ((oldPos.x - *X) * cos - (oldPos.y - *Y - (10 * Scale)) * sin) + *X;
				points[i].y = ((oldPos.x - *X) * sin + (oldPos.y - *Y - (10 * Scale)) * cos) + *Y;
			}

			if (IsMouseOver())
			{
				DrawText(scope $"Age: {boidStats.age}", int32(position.x - 30), int32(position.y - 90), 14, Color.BLACK);
				DrawText(scope $"Fitness: {CalculateFitness()}", int32(position.x - 30), int32(position.y - 70), 14, Color.BLACK);
				DrawText(scope $"Generation: {boidStats.generation+1}", int32(position.x - 30), int32(position.y - 50), 14, Color.BLACK);
				DrawText(scope $"Health: {boidStats.health}", int32(position.x - 30), int32(position.y - 30), 14, Color.BLACK);
			}

			if (currentMate != null && DebugView)
			{
				DrawLineV(position, currentMate.position, Color.PINK);
				DrawCircleV(matingSpot, 10, Color.PINK);
			}

			DrawTriangleFan(&points, 5, isPredator ? .(155, 0, 0, 255) : color);
		}

		public void ApplyForce(Vector2 force)
		{
			acceleration += force;
		}
		public void GetBoidsInRange(ref List<Entity> boids)
		{
			List<Entity> left = scope List<Entity>();
			List<Entity> right = scope List<Entity>();
			List<Entity> down = scope List<Entity>();
			List<Entity> up = scope List<Entity>();

			List<Entity> leftup = scope List<Entity>();
			List<Entity> rightup = scope List<Entity>();
			List<Entity> leftdown = scope List<Entity>();
			List<Entity> rightdown = scope List<Entity>();


			List<Entity> cur = scope List<Entity>();

			hash.QueryRelativePosition(this.position, 1, 0, 0, 0, ref left);
			hash.QueryRelativePosition(this.position, 0, 0, 1, 0, ref right);
			hash.QueryRelativePosition(this.position, 0, 0, 0, 1, ref down);
			hash.QueryRelativePosition(this.position, 0, 1, 0, 0, ref up);
			hash.QueryRelativePosition(this.position, 1, 1, 0, 0, ref leftup);
			hash.QueryRelativePosition(this.position, 1, 0, 0, 1, ref leftdown);
			hash.QueryRelativePosition(this.position, 0, 1, 1, 0, ref rightup);
			hash.QueryRelativePosition(this.position, 0, 0, 1, 1, ref rightdown);
			hash.QueryPosition(this.position, ref cur);

			boids.AddRange(left);
			boids.AddRange(right);
			boids.AddRange(down);
			boids.AddRange(up);

			boids.AddRange(leftup);
			boids.AddRange(rightup);
			boids.AddRange(leftdown);
			boids.AddRange(rightdown);
			boids.AddRange(cur);
		}

		public void BoidClicked()
		{
			SetCameraTarget(this);
		}
		public void BoidClicked2()
		{
			DisplayGenerationStats(this);
		}
		public override void Update()
		{
			base.Update();

			if (boidStats.age > boidStats.maxAge && boidStats.health > 0)
			{
				boidStats.health = -1;
			}

			if (boidStats.health <= 0)
			{
				deadFlag = true;
				if (currentMate != null)
				{
					//Died while trying to mate

					currentMate.currentMate = null;
					currentMate.hasReproduced = false;
					currentMate.boidStates.SwitchState("WanderState");
				}
			}
			if (deadFlag)
				return;

			position.x = position.x > worldWidth ? 30 : (position.x < 0 ? worldWidth - 30 : position.x);
			position.y = position.y > worldHeight ? 30 : (position.y < 0 ? worldHeight - 30 : position.y);

			GetBoidsInRange(ref boids);

			boidStates.Update();

			if (!isPredator)
			{
				Scale = Math.Max(boidStats.age / boidStats.maxAge, 0.6f);
				if (currentMate == null || !hasReproduced)
					boidStats.age += 1 * GetFrameTime();
			}
			velocity += acceleration;
			velocity=limitVec(velocity, boidStats.maxSpeed);
			position += velocity;
			acceleration *= 0;

			for (int i = 0; i < boids.Count; i++)
			{
				bool otherIsPredator = ((Boid)boids[i]).isPredator && !isPredator;
				float dist = Vector2Distance(((Boid)boids[i]).position, position);
				if (otherIsPredator && dist < 40)
				{
					boidStats.health -= 65 * GetFrameTime();

					boidStats.maxSpeed -= 0.1f * GetFrameTime();
					boidStats.maxForce -= 0.1f * GetFrameTime();
				}
			}

			boids.Clear();
		}



		public Vector2 align()
		{
			Vector2 alignment = Vector2.Zero;
			int total = 0;
			if (!isPredator)
			{
				for (int i = 0; i < boids.Count; i++)
				{
					if (boids[i] == null)
						continue;

					bool otherIsPredator = ((Boid)boids[i]).isPredator;
					if (otherIsPredator)
					{
						continue;
					}
					bool otherIsInFlock = flock.boids.Contains((Boid)boids[i]);
					float dist = Vector2Distance(position, boids[i].position);
					if (boids[i] != this && !otherIsPredator && otherIsInFlock && dist < 80)
					{
						total++;
						alignment += ((Boid)boids[i]).velocity;
					}
				}
			}
			if (total > 0 && alignment != Vector2.Zero)
			{
				alignment /= total;
				alignment = Vector2Normalize(alignment);
				alignment *= boidStats.maxSpeed;
				alignment -= (velocity);
				alignment=limitVec(alignment, boidStats.maxForce);
			}
			return alignment;
		}

		public Vector2 flee()
		{
			Vector2 flee = Vector2.Zero;
			for (int i = 0; i < boids.Count; i++)
			{
				if (boids[i] == null)
					continue;
				bool otherIsPredator = ((Boid)boids[i]).isPredator;
				float dist = Vector2Distance(position, boids[i].position);
				if (otherIsPredator && dist < 120)
				{
					flee += -Vector2Normalize(boids[i].position - position) / 4;
				}
			}
			return flee;
		}

		public Vector2 reproduce(Vector2 spot)
		{
			Vector2 attraction = Vector2.Zero;
			if (currentMate != null)
			{
				attraction = (spot - position);
				attraction = Vector2Normalize(attraction);
				attraction *= boidStats.maxSpeed;

				//attraction = limitVec(ref attraction, boidStats.maxForce);
			}
			return attraction;
		}


		public Vector2 cohese()
		{
			Vector2 cohesion = Vector2.Zero;
			int total = 0;

			for (int i = 0; i < boids.Count; i++)
			{
				if (boids[i] == null)
					continue;
				bool otherIsPredator = ((Boid)boids[i]).isPredator;
				bool otherIsInFlock = flock.boids.Contains((Boid)boids[i]);
				float dist = Vector2Distance(position, boids[i].position);
				if (!isPredator)
				{
					if (otherIsPredator)
						continue;
					if (boids[i] != this && !otherIsPredator && otherIsInFlock && dist < 80)
					{
						cohesion += boids[i].position;
						total++;
					}
				}
				else if (isPredator)
				{
					if (boids[i] != this && !otherIsPredator && !otherIsInFlock)
					{
						cohesion += boids[i].position;
						total++;
					}
				}
			}

			if (total > 0 && cohesion != Vector2.Zero)
			{
				cohesion /= total;
				//Get difference between current position and average flock position
				cohesion = cohesion - position;

				cohesion = Vector2Normalize(cohesion);
				cohesion *= boidStats.maxSpeed;
				cohesion -= velocity;
				cohesion=limitVec(cohesion, boidStats.maxForce);
			}
			return cohesion;
		}

		public Vector2 separate()
		{
			Vector2 separation = Vector2.Zero;
			int total = 0;
			for (int i = 0; i < boids.Count; i++)
			{
				if (boids[i] == null)
					continue;
				let d = Vector2Distance(position, boids[i].position);
				bool pred = ((Boid)boids[i]).isPredator;

				if ((boids[i] != this && d < 20) || (pred && !isPredator && boids[i] != this && d < 200))
				{
					Vector2 diff = Vector2Normalize((position - boids[i].position));
					if ((pred && isPredator) || (!pred && !isPredator))
						diff /= d * d;
					else if (pred && !isPredator)
						diff /= d * d * 4;
					separation += diff;
					total++;
				}
			}
			if (total > 0)
			{
				separation /= total;
			}
			if (Vector2Length(separation) > 0)
			{
				separation = Vector2Normalize(separation);
				separation *= boidStats.maxSpeed;
				separation -= velocity;
				separation=limitVec(separation, boidStats.maxForce);
			}


			return separation;
		}

		Vector2 randVector(float radius = 1)
		{
			double a = rand.NextDouble() * 2 * Math.PI_f;
			double r = radius * Math.Sqrt(rand.NextDouble());

			double x = r * Math.Cos(a);
			double y = r * Math.Sin(a);
			return Vector2((float)x, (float)y);
		}

	}
}
