using Boids.lib;
using System;
using System.Collections;

using raylib_beef.Types;
using static raylib_beef.Raylib;
using static raylib_beef.Raymath;
namespace Boids
{
	class Boid : Entity
	{
		Vector2 head;
		Vector2 tailL;
		Vector2 mid;
		Vector2 tailR;
		public Vector2 velocity;
		bool goal = true;
		Color color;
		List<Boid> boids ~ DeleteContainerAndItems!(_);
		public float heading { get; private set; }
		public this(float x, float y, float s, float r)
		{
			boids = new List<Boid>();
			position.x = x;
			position.y = y;
			Scale = s;
			Rotation = r;
			velocity = Vector2Normalize(randVector(1));
			heading = Math.Atan2(velocity.y, velocity.x) - (90 * DEG2RAD);
			Rotation = heading;
			float RandMultiplier = (float(scope Random().Next(8,10)))/10;
			float red =  234*RandMultiplier;
			float green = 170*RandMultiplier;
			float blue = 96*RandMultiplier;
			color=.(uint8(red),uint8(green),uint8(blue),255);
		
		}

		public ~this()
		{
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

			for(int i=0; i<boids.Count; i++){
				DrawLineV(position,boids[i].position,Color.RED);
			}

			DrawTriangleFan(&points, 5, color);
		}
		public override void Update()
		{
			float* X = &position.x;
			float* Y = &position.y;

			*X += velocity.x;
			*Y += velocity.y;
			//Why
			*X = *X > GetScreenWidth() + (10 * Scale) ? 0 - (9 * Scale) : (*X < 0 - (10 * Scale) ? GetScreenWidth() + (9 * Scale) : *X);
			*Y = *Y > GetScreenHeight() + (10 * Scale) ? 0 - (9 * Scale) : (*Y < 0 - (10 * Scale) ? GetScreenHeight() + (9 * Scale) : *Y);

			tree.FindClose(position,ref boids);

			velocity += align();
			velocity += cohese();
			velocity += separate();

			velocity.limitVec(3);
			boids.Clear();
		}

		public Vector2 align()
		{
			Vector2 alignment = Vector2.Zero;
			for (int i = 0; i < boids.Count; i++)
			{
				if (boids[i] != this && Vector2Distance(position,boids[i].position)<30)
				{
					alignment += boids[i].velocity;
				}
			}
			if (boids.Count > 0)
			{
				alignment /= boids.Count;
				alignment.limitVec(0.5f);
			}
			return alignment;
		}

		public Vector2 goal()
		{
			Vector2 goalVec = -position - GetMousePosition();
			goalVec.limitVec(0.5f);
			return goalVec;
		}

		public Vector2 cohese()
		{
			Vector2 cohesion = Vector2.Zero;
			for (int i = 0; i < boids.Count; i++)
			{
				if (boids[i] != this && Vector2Distance(position,boids[i].position)<30)
				{
					cohesion += boids[i].position;
				}
			}
			if (boids.Count > 0)
			{
				if(goal)
					cohesion+=GetMousePosition();
				cohesion /= boids.Count;
				cohesion -= position;
				cohesion -= velocity;
				cohesion.limitVec(0.1f);
			}
			return cohesion;
		}

		public Vector2 separate()
		{
			Vector2 separation = Vector2.Zero;
			int total = 0;
			for (int i = 0; i < boids.Count; i++)
			{
				let d = Vector2Distance(position, boids[i].position);
				if (boids[i] != this && d<20)
				{
					Vector2 diff = Vector2Normalize((position - boids[i].position));
					diff /= d * d;
					diff *= 50;
					//Increase separation power as we get closer
					separation += diff;
					total++;
				}
			}
			if (total > 0)
			{
				separation /= total;
				separation.limitVec(1f);
			}


			return separation;
		}

		Vector2 randVector(float radius = 1)
		{
			double a = scope Random().NextDouble() * 2 * Math.PI_f;
			double r = radius * Math.Sqrt(scope Random().NextDouble());

			double x = r * Math.Cos(a);
			double y = r * Math.Sin(a);
			return Vector2((float)x, (float)y);
		}

	}
}
