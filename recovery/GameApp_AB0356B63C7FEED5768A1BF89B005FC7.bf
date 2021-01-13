using System;
using System.Collections;
using static raylib_beef.Raylib;
using raylib_beef.Types;
using static raylib_beef.Raymath;
using Boids.lib;

namespace Boids
{
	static{
		public static GameApp app;

		public static Vector2 limitVec(this ref Vector2 vec, float maxLength)
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
		public static KDTree<Boid> tree;
		//public static SpatialHash<Boid> hash ~ delete _;
		//Extension methods for Raylib rectangle
		public static bool Contains(this Rectangle r, Vector2 point)
		{
			return (
				point.x >= r.x - r.width &&
				point.x < r.x + r.width &&
				point.y >= r.y - r.height &&
				point.y < r.y + r.height
			);
		}
		public static bool Intersects(this Rectangle r, Rectangle r2)
		{
			return !(
				r2.x - r2.width > r.x + r.width   ||
				r2.x + r2.height < r.x - r.width  ||
				r2.y - r2.height > r.y + r.height ||
				r2.y + r2.height  < r.y - r.height
			);
		}


	}

	class GameApp 
	{
		const int screenWidth=1200;
		const int screenHeight=720;
		public List<Boid> boids;
		Random mRand = new Random() ~ delete _;
		public this(){
			app=this;


			Init();
		}

		public ~this(){
			delete(tree);
			DeleteAndClearItems!(boids);
		}
		public void Init(){
			tree=new KDTree<Boid>(false);
			boids=new List<Boid>();
			let pi = Math.PI_f;
			for(int i=0; i<3000; i++){
				let b = new Boid(mRand.Next(0,1200),mRand.Next(0,720),float(mRand.Next(10,18))/10,45);
				tree.Add(b);
				boids.Add(b);

			}	
		}
		float angle = 0;
		public void Update()
		{
			tree.UpdatePositions();

			if(IsMouseButtonDown(0)){
				List<Boid> b = scope List<Boid>();

				tree.FindClose(GetMousePosition(),ref b);

				for(int i=0;  i<b.Count; i++){
					if(Vector2Distance(GetMousePosition(),b[i].position)<50){
						b[i].velocity+= Vector2Normalize(b[i].position-GetMousePosition());
					}
				}
			}

			if(IsMouseButtonDown(raylib_beef.Enums.MouseButton.MOUSE_RIGHT_BUTTON)){
				List<Boid> b = scope List<Boid>();

				tree.FindClose(GetMousePosition(),ref b);

				for(int i=0;  i<b.Count; i++){
					if(Vector2Distance(GetMousePosition(),b[i].position)<){
						b[i].velocity+= -Vector2Normalize(b[i].position-GetMousePosition());
					}
				}
			}

			for(int i=0; i<boids.Count; i++){
				boids[i].Update();
				//hash.UpdatePosition(boids[i].position,boids[i]);
			}
		
		}
		public void Draw()
		{
			BeginDrawing();
			ClearBackground(.(255, 255, 255, 255));
			for(int i=0; i<boids.Count; i++){
				boids[i].Draw();
			}
			//tree.Draw();

			EndDrawing();
		}
	}
}
