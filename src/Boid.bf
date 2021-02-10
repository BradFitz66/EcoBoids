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

		float maxSpeed=3f;
		float maxForce=0.03f;

		public Vector2 acceleration;
		public Vector2 prevPosition;
		public Vector2 velocity;

		bool goal = false;
		Color color;

		List<Entity> boids ~ DeleteContainerAndItems!(_);

		public float heading { get; private set; }

		public this(float x, float y, float s, float r)
		{
			aabb=Rectangle(x,y,20,20);
			boids = new List<Entity>();
			position.x = x;
			position.y = y;
			Scale = s;
			Rotation = r;
			acceleration = Vector2Normalize(randVector(10));
			heading = Math.Atan2(acceleration.y, acceleration.x) - (90 * DEG2RAD);
			Rotation = heading;
			float RandMultiplier = (float(scope Random().Next(8,10)))/10;
			float red =  234*RandMultiplier;
			float green = 170*RandMultiplier;
			float blue = 96*RandMultiplier;
			color=.(uint8(red),uint8(green),uint8(blue),255);
		
		}



		public Vector2 limitVec(ref Vector2 vec, float maxLength) 
		{

			let lengthSquared = vec.x * vec.x + vec.y * vec.y;

			if ((lengthSquared > maxLength * maxLength) && (lengthSquared > 0))
			{
				let ratio = maxLength / Math.Sqrt(lengthSquared);
				vec.x *= ratio;
				vec.y *= ratio;
			}

			return vec;
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

		void ApplyForce(Vector2 force){
			acceleration+=force;
		}

		public override void Update()
		{


			//Why
			position.x = position.x > worldWidth ? 0 : (position.x < 0 ? worldWidth : position.x);
			position.y = position.y > worldHeight ? 0 : (position.y < 0 ? worldHeight : position.y);	
			/*if(!spatialHash)
				tree.getItemsInRadius(ref boids,position.x,position.y,150);
			else*/

			hash.QueryPosition(this.position,ref boids);

			ApplyForce(separate()*2.5f);
			ApplyForce(align()*1.5f);
			ApplyForce(cohese()*1.3f);

			velocity+=acceleration;
			velocity=limitVec(ref velocity,maxSpeed);


			position += velocity;


			acceleration*=0;
			boids.Clear();

		}



		public Vector2 align()
		{
			Vector2 alignment = Vector2.Zero;
			int total=0;
			for (int i = 0; i < boids.Count; i++)
			{
				if (boids[i] != this && Vector2Distance(position,boids[i].position)<40)
				{
					total++;
					alignment += ((Boid)boids[i]).velocity;
				}
			}
			if (total > 0 && alignment != Vector2.Zero)
			{
				alignment/=total;
				alignment=Vector2Normalize(alignment);
				alignment*=maxSpeed;
				alignment-=(velocity);
				alignment=limitVec(ref alignment,maxForce);
			}
			return alignment;
		}

		public Vector2 cohese()
		{
			Vector2 cohesion = Vector2.Zero;
			int total =0;
			for (int i = 0; i < boids.Count; i++)
			{
				if (boids[i] != this && Vector2Distance(position,boids[i].position)<40)
				{
					cohesion += boids[i].position;
					total++;
				}
			}
			if (total > 0 && cohesion!=Vector2.Zero)
			{
				cohesion /= total;
				if(goal)
					cohesion+=(GetScreenToWorld2D(GetMousePosition(),cam)-position);
				//Get difference between current position and average flock position
				cohesion = cohesion - position;
				
				cohesion=Vector2Normalize(cohesion);
				cohesion*=maxSpeed;
				cohesion-=velocity;
				cohesion=limitVec(ref cohesion,maxForce);
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
					diff /= d*d;
					//Increase separation power as we get closer
					separation += diff;
					total++;
				}
			}
			if (total > 0)
			{
				separation /= total;
			}
			if(Vector2Length(separation)>0){
				separation=Vector2Normalize(separation);
				separation*=maxSpeed;
				separation-=velocity;
				separation=limitVec(ref separation,maxForce);
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
