using System;
using System.Collections;
using System.Linq;
using static raylib_beef.Raylib;
using raylib_beef.Types;
namespace Boids
{
	class Flock
	{
		public List<Boid> boids ~ delete _;
		Color flockColor;

		public this(int amount,float x, float y, int flockRadius){
			boids=new List<Boid>();
			flockColor=generateRandomColor(.(255,165,255,255));
			for(int i=0; i<amount; i++){
				Vector2 rVec=randVector(flockRadius);
				Boid b = new Boid(x+rVec.x,y+rVec.y,1,0);
				boids.Add(b);
				b.flock=this;
				b.color=flockColor;
				hash.Insert(b.position,b);
			}
		}

		public void Update(){
			for(int i=0; i<boids.Count; i++){
				boids[i].prevPosition=.(boids[i].position.x,boids[i].position.y);
				boids[i].Update();
			}

			for(int i=0; i<boids.Count; i++){
				hash.UpdatePosition(boids[i].position,boids[i].prevPosition,boids[i]);
			}

		}


		public void Draw(){
			for(int i=0; i<boids.Count; i++){
				boids[i].Draw();
			}
		}
		public Color generateRandomColor(Color mix) {
		    Random random = scope Random();
		    int red = random.Next(256);
		    int green = random.Next(256);
		    int blue = random.Next(256);

		    // mix the color
		    if (mix != null) {
		        red = (red + mix.r) / 2;
		        green = (green + mix.g) / 2;
		        blue = (blue + mix.b) / 2;
		    }

		    Color color = .((uint8)red, (uint8)green, (uint8)blue,(uint8)255);
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
