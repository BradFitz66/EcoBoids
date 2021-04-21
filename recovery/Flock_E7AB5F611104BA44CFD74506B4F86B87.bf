using System;
using System.Collections;
using System.Linq;
using static raylib_beef.Raylib;
using raylib_beef.Types;
namespace Boids
{
	/*
	Title: Flock
	Description: A flock that contains a set amount of boids. Boids will only cohese and align with their own flock.
	*/
	class Flock
	{
		public List<Boid> boids ~ delete _5;
		public Color flockColor{get; private set;};
		public Color flockMixColor = Color.WHITE;

		public this(int amount, float x, float y, int flockRadius, bool isPredatorFlock = false)
		{
			boids = new List<Boid>();
			flockColor = generateRandomColor(flockMixColor);
			for (int i = 0; i < amount; i++)
			{
				Vector2 rVec = randVector(flockRadius);
				Boid b = new Boid(x + rVec.x, y + rVec.y, 1, 0, isPredatorFlock);
				boids.Add(b);
				b.flock = this;
				b.color = flockColor;
				hash.Add(b);
			}
		}

		public void Update()
		{
			for (int i = 0; i < boids.Count; i++)
			{
				if (boids[i].deadFlag)
				{
					DeleteAndNullify!(boids[i]);
					boids.Remove(boids[i]);
					continue;
				}
				boids[i].prevPosition = .(boids[i].position.x, boids[i].position.y);
				boids[i].Update();
				hash.UpdatePosition(boids[i].position, boids[i].prevPosition, boids[i]);
			}
		}


		public void Draw()
		{
			for (int i = 0; i < boids.Count; i++)
			{
				boids[i].Draw();
			}
		}
		public Color generateRandomColor(Color mix)
		{
			Random random = scope Random();
			int red = random.Next(128) + 63;
			int green = random.Next(128) + 63;
			int blue = random.Next(128) + 63;

			// mix the color
			if (mix != null)
			{
				red = (red + mix.r) / 2;
				green = (green + mix.g) / 2;
				blue = (blue + mix.b) / 2;
			}
			Color color = .((uint8)red, (uint8)green, (uint8)blue, (uint8)255);
			return color;
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
